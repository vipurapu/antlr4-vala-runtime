/* atnconfigset.vala
 *
 * Copyright 2020 Valio Valtokari <ubuntugeek1904@gmail.com>
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 * SPDX-License-Identifier: Apache-2.0
 */
using Antlr4.Runtime.Misc;
using Antlr4.Runtime.Error;

/**
 * Specialized {@link Set}{@code <}{@link ATNConfig}{@code >} that can track
 * info about the set, with support for combining similar configurations using a
 * graph-structured stack.
 */
public class Antlr4.Runtime.Atn.ATNConfigSet : Gee.Set<ATNConfig>
{
	/**
	 * The reason that we need this is because we don't want the hash map to use
	 * the standard hash code and equals. We need all configurations with the same
	 * {@code (s,i,_,semctx)} to be equal. Unfortunately, this key effectively doubles
	 * the number of objects associated with ATNConfigs. The other solution is to
	 * use a hash table that lets us specify the equals/hashcode operation.
	 */
	public class ConfigHashSet : AbstractConfigHashSet
	{
		public ConfigHashSet()
		{
			base(ConfigEqualityComparator.INSTANCE);
		}
	}

	public class ConfigEqualityComparator : AbstractEqualityComparator<ATNConfig>
	{
		public static ConfigEqualityComparator INSTANCE { get; default = new ConfigEqualityComparator(); }

		private ConfigEqualityComparator() {  }

		public override uint64 hash_code(ATNConfig o)
		{
			uint64 hash = 7;
			hash = 31 * hash + o.state.state;
			hash = 31 * hash + o.alt;
			hash = 31 * hash + o.semantic_context.hash_code();
	        return hash;
		}

		public bool equals(ATNConfig a, ATNConfig b)
		{
			if (a == b) return true;
			if (a == null || b == null) return false;
			return a.state.state_number == b.state.state_number
				&& a.alt == b.alt
				&& a.semantic_context.equals(b.semantic_context);
		}
	}

	/**
	 * Indicates that the set of configurations is read-only. Do not
	 * allow any code to manipulate the set; DFA states will point at
	 * the sets and they must not change. This does not protect the other
	 * fields; in particular, conflicting_alts is set after
	 * we've made this readonly.
 	 */
	protected bool readonly = false;

	/**
	 * All configs but hashed by (s, i, _, pi) not including context. Wiped out
	 * when we go readonly as this set becomes a DFA state.
	 */
	public AbstractConfigHashSet config_lookup;

	/** Track the elements as they are added to the set; supports get(i) */
	public Gee.ArrayList<ATNConfig> configs { get; default = new Gee.ArrayList<ATNConfig>(7); }

	// TODO: these fields make me pretty uncomfortable but nice to pack up info together, saves recomputation
	// TODO: can we track conflicts as they are added to save scanning configs later?
	public int unique_alt;
	/** Currently this is only used when we detect SLL conflict; this does
	 *  not necessarily represent the ambiguous alternatives. In fact,
	 *  I should also point out that this seems to include predicated alternatives
	 *  that have predicates that evaluate to false. Computed in computeTargetState().
 	 */
	protected BitSet conflicting_alts;

	// Used in parser and lexer. In lexer, it indicates we hit a pred
	// while computing a closure operation.  Don't make a DFA state from this.
	public bool has_semantic_context;
	public bool dips_into_outer_context;

	/** Indicates that this configuration set is part of a full context
	 *  LL prediction. It will be used to determine how to merge $. With SLL
	 *  it's a wildcard whereas it is not for LL context merge.
	 */
	public bool full_ctx { get; construct; }

	private int cached_hash_code = -1;

	public ATNConfigSet(bool full_ctx = true)
	{
		config_lookup = new ConfigHashSet();
		this.full_ctx = full_ctx;
	}

	public ATNConfigSet.dup(ATNConfigSet old)
	{
		this(old.full_ctx);
		add_all(old);
		this.unique_alt = old.unique_alt;
		this.conflicting_alts = old.conflicting_alts;
		this.has_semantic_context = old.has_semantic_context;
		this.dips_into_outer_context = old.dips_into_outer_context;
	}

	public bool add(ATNConfig config)
	{
		return add_with_keymap(config, null);
	}

	/**
	 * Adding a new config means merging contexts with existing configs for
	 * {@code (s, i, pi, _)}, where {@code s} is the
	 * {@link ATNConfig#state}, {@code i} is the {@link ATNConfig#alt}, and
	 * {@code pi} is the {@link ATNConfig#semanticContext}. We use
	 * {@code (s,i,pi)} as key.
	 *
	 * <p>This method updates {@link #dips_into_outer_context} and
	 * {@link #has_semantic_context} when necessary.</p>
	 */
	public bool add_with_keymap(
		ATNConfig config,
		DoubleKeyMap<PredictionContext, PredictionContext, PredictionContext>? merge_cache) throws StateError
	{
		if (readonly) throw new StateError.ILLEGAL_STATE("This set is readonly");
		if ( config.semanticContext!=SemanticContext.NONE ) {
			has_semantic_context = true;
		}
		if (config.getOuterContextDepth() > 0) {
			dips_into_outer_context = true;
		}
		ATNConfig existing = config_lookup.getOrAdd(config);
		if ( existing==config ) { // we added this new one
			cached_hash_code = -1;
			configs.add(config);  // track order here
			return true;
		}
		// a previous (s,i,pi,_), merge with it and save result
		bool rootIsWildcard = !full_ctx;
		PredictionContext merged =
			PredictionContext.merge(existing.context, config.context, rootIsWildcard, merge_cache);
		// no need to check for existing.context, config.context in cache
		// since only way to create new graphs is "call rule" and here. We
		// cache at both places.
		existing.reachesIntoOuterContext =
			Math.max(existing.reachesIntoOuterContext, config.reachesIntoOuterContext);

		// make sure to preserve the precedence filter suppression during the merge
		if (config.isPrecedenceFilterSuppressed()) {
			existing.setPrecedenceFilterSuppressed(true);
		}

		existing.context = merged; // replace context; no need to alt mapping
		return true;
	}

	/** Return a List holding list of configs */
    public List<ATNConfig> elements() { return configs; }

	public Set<ATNState> getStates() {
		Set<ATNState> states = new HashSet<ATNState>();
		for (ATNConfig c : configs) {
			states.add(c.state);
		}
		return states;
	}

	/**
	 * Gets the complete set of represented alternatives for the configuration
	 * set.
	 *
	 * @return the set of represented alternatives in this configuration set
	 *
	 * @since 4.3
	 */

	public BitSet getAlts() {
		BitSet alts = new BitSet();
		for (ATNConfig config : configs) {
			alts.set(config.alt);
		}
		return alts;
	}

	public List<SemanticContext> getPredicates() {
		List<SemanticContext> preds = new ArrayList<SemanticContext>();
		for (ATNConfig c : configs) {
			if ( c.semanticContext!=SemanticContext.NONE ) {
				preds.add(c.semanticContext);
			}
		}
		return preds;
	}

	public ATNConfig get(int i) { return configs.get(i); }

	public void optimizeConfigs(ATNSimulator interpreter) {
		if ( readonly ) throw new IllegalStateException("This set is readonly");
		if ( config_lookup.isEmpty() ) return;

		for (ATNConfig config : configs) {
//			int before = PredictionContext.getAllContextNodes(config.context).size();
			config.context = interpreter.getCachedContext(config.context);
//			int after = PredictionContext.getAllContextNodes(config.context).size();
//			System.out.println("configs "+before+"->"+after);
		}
	}

	@Override
	public bool add_all(Collection<? extends ATNConfig> coll) {
		for (ATNConfig c : coll) add(c);
		return false;
	}

	@Override
	public bool equals(Object o) {
		if (o == this) {
			return true;
		}
		else if (!(o instanceof ATNConfigSet)) {
			return false;
		}

//		System.out.print("equals " + this + ", " + o+" = ");
		ATNConfigSet other = (ATNConfigSet)o;
		bool same = configs!=null &&
			configs.equals(other.configs) &&  // includes stack context
			this.full_ctx == other.full_ctx &&
			this.unique_alt == other.unique_alt &&
			this.conflicting_alts == other.conflicting_alts &&
			this.has_semantic_context == other.has_semantic_context &&
			this.dips_into_outer_context == other.dips_into_outer_context;

//		System.out.println(same);
		return same;
	}

	@Override
	public int hashCode() {
		if (isReadonly()) {
			if (cached_hash_code == -1) {
				cached_hash_code = configs.hashCode();
			}

			return cached_hash_code;
		}

		return configs.hashCode();
	}

	@Override
	public int size() {
		return configs.size();
	}

	@Override
	public bool isEmpty() {
		return configs.isEmpty();
	}

	@Override
	public bool contains(Object o) {
		if (config_lookup == null) {
			throw new UnsupportedOperationException("This method is not implemented for readonly sets.");
		}

		return config_lookup.contains(o);
	}

	public bool containsFast(ATNConfig obj) {
		if (config_lookup == null) {
			throw new UnsupportedOperationException("This method is not implemented for readonly sets.");
		}

		return config_lookup.containsFast(obj);
	}

	@Override
	public Iterator<ATNConfig> iterator() {
		return configs.iterator();
	}

	@Override
	public void clear() {
		if ( readonly ) throw new IllegalStateException("This set is readonly");
		configs.clear();
		cached_hash_code = -1;
		config_lookup.clear();
	}

	public bool isReadonly() {
		return readonly;
	}

	public void setReadonly(bool readonly) {
		this.readonly = readonly;
		config_lookup = null; // can't mod, no need for lookup cache
	}

	@Override
	public String toString() {
		StringBuilder buf = new StringBuilder();
		buf.append(elements().toString());
		if ( has_semantic_context ) buf.append(",has_semantic_context=").append(has_semantic_context);
		if ( unique_alt!=ATN.INVALID_ALT_NUMBER ) buf.append(",unique_alt=").append(unique_alt);
		if ( conflicting_alts!=null ) buf.append(",conflicting_alts=").append(conflicting_alts);
		if ( dips_into_outer_context ) buf.append(",dips_into_outer_context");
		return buf.toString();
	}

	// satisfy interface

	@Override
	public ATNConfig[] toArray() {
		return config_lookup.toArray();
	}

	@Override
	public <T> T[] toArray(T[] a) {
		return config_lookup.toArray(a);
	}

	@Override
	public bool remove(Object o) {
		throw new UnsupportedOperationException();
	}

	@Override
	public bool containsAll(Collection<?> c) {
		throw new UnsupportedOperationException();
	}

	@Override
	public bool retainAll(Collection<?> c) {
		throw new UnsupportedOperationException();
	}

	@Override
	public bool removeAll(Collection<?> c) {
		throw new UnsupportedOperationException();
	}

	public static abstract class AbstractConfigHashSet extends Array2DHashSet<ATNConfig> {

		public AbstractConfigHashSet(AbstractEqualityComparator<? super ATNConfig> comparator) {
			this(comparator, 16, 2);
		}

		public AbstractConfigHashSet(AbstractEqualityComparator<? super ATNConfig> comparator, int initialCapacity, int initialBucketCapacity) {
			super(comparator, initialCapacity, initialBucketCapacity);
		}

		@Override
		protected /* final */ ATNConfig asElementType(Object o) {
			if (!(o instanceof ATNConfig)) {
				return null;
			}

			return (ATNConfig)o;
		}

		@Override
		protected /* final */ ATNConfig[][] createBuckets(int capacity) {
			return new ATNConfig[capacity][];
		}

		@Override
		protected /* final */ ATNConfig[] createBucket(int capacity) {
			return new ATNConfig[capacity];
		}

	}
}
