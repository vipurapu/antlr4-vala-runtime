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
 * Specialized {@link Set}{{{<}}}{@link ATNConfig}{{{>}}} that can track
 * info about the set, with support for combining similar configurations using a
 * graph-structured stack.
 */
public class Antlr4.Runtime.Atn.ATNConfigSet : Gee.HashSet<ATNConfig>, Hashable
{
	/**
	 * The reason that we need this is because we don't want the hash map to use
	 * the standard hash code and equals. We need all configurations with the same
	 * {{{(s,i,_,semctx)}}} to be equal. Unfortunately, this key effectively doubles
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
	public AbstractConfigHashSet? config_lookup;

	/** Track the elements as they are added to the set; supports get(i) */
	public Gee.ArrayList<ATNConfig> configs { get; default = new Gee.ArrayList<ATNConfig>(7); }

	// TODO: these fields make me pretty uncomfortable but nice to pack up info together, saves recomputation
	// TODO: can we track conflicts as they are added to save scanning configs later?
	public int unique_alt;
	/**
	 * Currently this is only used when we detect SLL conflict; this does
	 * not necessarily represent the ambiguous alternatives. In fact,
	 * I should also point out that this seems to include predicated alternatives
	 * that have predicates that evaluate to false. Computed in computeTargetState().
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
	 * {{{(s, i, pi, _)}}}, where {{{s}}} is the
	 * {@link ATNConfig#state}, {{{i}}} is the {@link ATNConfig#alt}, and
	 * {{{pi}}} is the {@link ATNConfig#semanticContext}. We use
	 * {{{(s,i,pi)}}} as key.
	 *
	 * This method updates {@link #dips_into_outer_context} and
	 * {@link #has_semantic_context} when necessary.
	 */
	public bool add_with_keymap(
		ATNConfig config,
		DoubleKeyMap<PredictionContext, PredictionContext, PredictionContext>? merge_cache) throws StateError
	{
		if (readonly) throw new StateError.ILLEGAL_STATE("This set is readonly");
		if (config.semantic_context != SemanticContext.NONE)
			has_semantic_context = true;

		if (config.outer_context_depth > 0)
			dips_into_outer_context = true;

		ATNConfig existing = config_lookup.get_or_add(config);
		if (existing == config) // we added this new one
		{
			cached_hash_code = -1;
			configs.add(config);  // track order here
			return true;
		}
		// a previous (s,i,pi,_), merge with it and save result
		bool root_is_wildcard = !full_ctx;
		PredictionContext merged =
			PredictionContext.merge(existing.context, config.context, root_is_wildcard, merge_cache);
		// no need to check for existing.context, config.context in cache
		// since only way to create new graphs is "call rule" and here. We
		// cache at both places.
		existing.reaches_into_outer_context =
			Util.max(existing.reaches_into_outer_context, config.reaches_into_outer_context);

		// make sure to preserve the precedence filter suppression during the merge
		if (config.precedence_filter_suppressed)
			existing.precedence_filter_suppressed = true;

		existing.context = merged; // replace context; no need to alt mapping
		return true;
	}

	/** Return a List holding list of configs */
    public Gee.List<ATNConfig> elements { get { return configs; } }

	public Gee.Set<ATNState> states
	{
	    get
	    {
	    	Gee.Set<ATNState> states = new Gee.HashSet<ATNState>();
		    foreach (ATNConfig c in configs)
			    states.add(c.state);
		    return states;
		}
	}

	/**
	 * The complete set of represented alternatives for the configuration
	 * set.
	 *
	 * @since 4.3
	 */
	[Version (since = "4.3")]
	public BitSet alts
	{
	    get
	    {
		    BitSet alts = new BitSet();
		    foreach (ATNConfig config in configs)
			    alts.set(config.alt);
		    return alts;
		}
	}

	public Gee.List<SemanticContext> predicates
	{
	    get
	    {
		    Gee.List<SemanticContext> preds = new Gee.ArrayList<SemanticContext>();
		    foreach (ATNConfig c in configs)
		    {
			    if (c.semantic_context != SemanticContext.NONE )
			    	preds.add(c.semantic_context);
		    }
		    return preds;
		}
	}

	public ATNConfig get(int i) { return configs[i]; }

	public void optimize_configs(ATNSimulator interpreter)
	{
		if (readonly) throw new StateError.ILLEGAL_STATE("This set is readonly");
		if (config_lookup.is_empty) return;

		foreach (ATNConfig config in configs)
		{
//			int before = PredictionContext.get_all_context_nodes(config.context).size;
			config.context = interpreter.get_cached_context(config.context);
//			int after = PredictionContext.get_all_context_nodes(config.context).size;
//			stdout.printf("configs %d->%d", before, after);
		}
	}

	public bool add_all(Gee.Collection<ATNConfig> coll)
	{
		foreach (ATNConfig c in coll) add(c);
		return false;
	}

	public bool equals(ATNConfigSet? o)
	{
		if (o == this)
			return true;

//		stdout.printf("equals %s, %s = ", this, o);
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

	public override uint64 hash_code()
	{
		if (readonly)
		{
			if (cached_hash_code == -1)
				cached_hash_code = configs.hash_code();

			return cached_hash_code;
		}

		return configs.hash_code();
	}

	public int size
	{
	    get
	    {
		    return configs.size;
		}
	}

	public bool is_empty
	{
	    get
	    {
		    return configs.is_empty;
		}
	}

	public bool contains(ATNConfig o) throws StateError
	{
		if (config_lookup == null) throw new StateError.ILLEGAL_STATE("This method is not implemented for readonly sets.");

		return config_lookup.contains(o);
	}

	public bool contains_fast(ATNConfig obj) throws StateError
	{
		if (config_lookup == null) throw new StateError.ILLEGAL_STATE("This method is not implemented for readonly sets.");

		return config_lookup.contains_fast(obj);
	}

	public Gee.Iterator<ATNConfig> iterator
	{
	    get
	    {
		    return configs.iterator;
		}
	}

	public void clear()
	{
		if (readonly) throw new StateError.ILLEGAL_STATE("This set is readonly");
		configs.clear();
		cached_hash_code = -1;
		config_lookup.clear();
	}

	public bool readonly
	{
	    get
	    {
		    return readonly;
		}
		set
		{
		    this.readonly = value;
		    config_lookup = null;
		}
	}

	public string to_string()
	{
		StringBuilder buf = new StringBuilder();
		var element_strs = new string[elements.size];
		for (var i = 0; i < elements; i++) element_strs[i] = elements[i].to_string();
		buf.append(Util.join_string("[", "]", ", ", element_strs));
		if (has_semantic_context) buf.append(", has_semantic_context: true");
		if (unique_alt != ATN.INVALID_ALT_NUMBER) buf.append(", unique_alt: " + unique_alt.to_string());
		if (conflicting_alts != null) buf.append(", conflicting_alts: ").append(conflicting_alts.to_string());
		if (dips_into_outer_context) buf.append(", dips_into_outer_context: true");
		return buf.str;
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

	public abstract class AbstractConfigHashSet : Gee.HashSet<AtnConfig>
	{

		public AbstractConfigHashSet(AbstractEqualityComparator<ATNConfig> comparator)
		{
			this(comparator, 16, 2);
		}

		public AbstractConfigHashSet(AbstractEqualityComparator<? super ATNConfig> comparator, int initialCapacity, int initialBucketCapacity) {
			super(comparator, initialCapacity, initialBucketCapacity);
		}

		protected /* final */ ATNConfig asElementType(Object o) {
			if (!(o instanceof ATNConfig)) {
				return null;
			}

			return (ATNConfig)o;
		}

		protected sealed Gee.List<Gee.List<AtnConfig>> create_buckets(int capacity)
		{
			var result = new Gee.ArrayList<Gee.List<AtnConfig>>();
			result.add_all(create_bucket(capacity));
			return result;
		}

		protected sealed Gee.List<AtnConfig> create_bucket(int capacity)
		{
			return new Gee.ArrayList<ATNConfig>.wrap(new AtnConfig[capacity]);
		}
	}
}
