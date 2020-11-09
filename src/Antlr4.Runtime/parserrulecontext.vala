/* parserrulecontext.vala
 *
 * Copyright 2020 Valio Valtokari <ubuntugeek1904@gmail.com>
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 * SPDX-License-Identifier: Apache-2.0
 */
using Antlr4.Runtime.Tree;
using Antlr4.Runtime.Error;

/**
 * A rule invocation record for parsing.
 *
 * Contains all of the information about the current rule not stored in the
 * RuleContext. It handles parse tree children list, Any ATN state
 * tracing, and the default values available for rule invocations:
 * start, stop, rule index, current alt number.
 *
 * Subclasses made for each rule and grammar track the parameters,
 * return values, locals, and labels specific to that rule. These
 * are the objects that are returned from rules.
 *
 * Note text is not an actual field of a rule return value; it is computed
 * from start and stop using the input stream's {{{toString()}}} method.  I
 * could add a ctor to this so that we can pass in and store the input
 * stream, but I'm not sure we want to do that.  It would seem to be undefined
 * to get the .text property anyway if the rule matches tokens from multiple
 * input streams.
 *
 * I do not use getters for fields of objects that are used simply to
 * group values such as this aggregate.  The getters/setters are there to
 * satisfy the superclass interface.
 */
public class Antlr4.Runtime.ParserRuleContext : RuleContext
{
	/** If we are debugging or building a parse tree for a visitor,
	 * we need to track all of the tokens and rule invocations associated
	 * with this rule's context. This is empty for parsing w/o tree constr.
	 * operation because we don't the need to track the details about
	 * how we parse this rule.
	 */
	public Gee.List<ParseTree> children;

	/**
	 * For debugging/tracing purposes, we want to track all of the nodes in
	 * the ATN traversed by the parser for a particular rule.
	 * This list indicates the sequence of ATN nodes used to match
	 * the elements of the children list. This list does not include
	 * ATN nodes and other rules used to match rule invocations. It
	 * traces the rule invocation node itself but nothing inside that
	 * other rule's ATN submachine.
	 *
	 * There is NOT a one-to-one correspondence between the children and
	 * states list. There are typically many nodes in the ATN traversed
	 * for each element in the children list. For example, for a rule
	 * invocation there is the invoking state and the following state.
	 *
	 * The parser {{{setState()}}} method updates field s and adds it to this
	 * list if we are debugging/tracing.
	 *
	 * This does not trace states visited during prediction.
	 */
//	public Gee.List<int> states;

	public Token start;
	public Token stop;

	/**
	 * The error that forced this rule to return. If the rule successfully
	 * completed, this is {{{null}}}.
	 */
	public RecognitionError? error;

	public ParserRuleContext.empty()
	{
	    base.empty();
	}

	/**
	 * COPY a ctx (I'm deliberately not using copy constructor) to avoid
	 * confusion with creating node with parent. Does not copy children
	 * (except error leaves).
	 *
	 * This is used in the generated parser code to flip a generic XContext
	 * node for rule X to a YContext for alt label Y. In that sense, it is
	 * not really a generic copy function.
	 *
	 * If we do an error sync() at start of a rule, we might add error nodes
	 * to the generic XContext so this function must copy those nodes to
	 * the YContext as well else they are lost!
	 */
	public void copy_from(ParserRuleContext ctx)
	{
		this.parent = ctx.parent;
		this.invoking_state = ctx.invoking_state;

		this.start = ctx.start;
		this.stop = ctx.stop;

		// copy any error nodes to alt label node
		if (ctx.children != null)
		{
			this.children = new Gee.ArrayList<ParseTree>();
			// reset parent pointer for any error nodes
			foreach (ParseTree child in ctx.children)
			{
				if (child is ErrorNode)
					add_child(child as ErrorNode);
			}
		}
	}

	public ParserRuleContext(ParserRuleContext parent, int invoking_state_number)
	{
		base(parent, invoking_state_number);
	}

	// Double dispatch methods for listeners

	public void enter_rule(ParseTreeListener listener) {  }
	public void exit_rule(ParseTreeListener listener) {  }

	/**
	 * Add a parse tree node to this as a child.  Works for
	 * internal and leaf nodes. Does not set parent link;
	 * other add methods must do that. Other addChild methods
	 * call this.
	 *
	 * We cannot set the parent pointer of the incoming node
	 * because the existing interfaces do not have a setParent()
	 * method and I don't want to break backward compatibility for this.
	 *
	 * @since 4.7
	 */
	public T add_any_child<T>(T t) requires (t is ParseTree)
	{
		if (children == null) children = new Gee.ArrayList<ParseTree>();
		children.add(t as ParseTree);
		return t;
	}

	public RuleContext add_child(RuleContext rule_invocation)
	{
		return add_any_child(rule_invocation);
	}

	/** Add a token leaf node child and force its parent to be this node. */
	public TerminalNode add_leaf(TerminalNode t)
	{
		t.parent = this;
		return add_any_child(t);
	}

	/**
	 * Add an error node child and force its parent to be this node.
	 *
	 * @since 4.7
	 */
	[Version(since = "4.7")]
	public ErrorNode add_error_node(ErrorNode en)
	{
		en.parent = this;
		return add_any_child(en);
	}

	/**
	 * Add a child to this node based upon matchedToken. It
	 * creates a TerminalNodeImpl rather than using
	 * {@link Parser#createTerminalNode(ParserRuleContext, Token)}. I'm leaving this
     * in for compatibility but the parser doesn't use this anymore.
	 */
	[Version (deprecated = true)]
	public TerminalNode add_token_child(Token matched_token)
	{
		TerminalNodeImpl t = new TerminalNodeImpl(matched_token);
		add_any_child(t);
		t.parent = this;
		return t;
	}

	/**
	 * Add a child to this node based upon badToken.  It
	 * creates a ErrorNodeImpl rather than using
	 * {@link Parser#createErrorNode(ParserRuleContext, Token)}. I'm leaving this
	 * in for compatibility but the parser doesn't use this anymore.
	 */
	[Version (deprecated = true)]
	public ErrorNode add_error_node_from_token(Token bad_token)
	{
		ErrorNodeImpl t = new ErrorNodeImpl(bad_token);
		add_any_child(t);
		t.parent = this;
		return t;
	}

//	public void trace(int s)
//  {
//		if (states == null) states = new Gee.ArrayList<int?>();
//		states.add(s);
//	}

	/**
	 * Used by enterOuterAlt to toss out a RuleContext previously added as
	 * we entered a rule. If we have # label, we will need to remove
	 * generic ruleContext object.
	 */
	public void remove_last_child()
	{
		if (children != null)
			children.remove_at(children.size - 1);
	}

	/** Override to make type more specific */
	public new ParserRuleContext parent
	{
	    get
	    {
		    return base.parent as ParserRuleContext;
		}
	}

	public new ParseTree? child_at(int i)
	{
		return children != null && i >= 0 && i < children.size ? children[i] : null;
	}

	public TerminalNode get_token(int ttype, int i)
	{
		if ( children==null || i < 0 || i >= children.size() ) {
			return null;
		}

		int j = -1; // what token with ttype have we found?
		for (ParseTree o : children) {
			if ( o instanceof TerminalNode ) {
				TerminalNode tnode = (TerminalNode)o;
				Token symbol = tnode.getSymbol();
				if ( symbol.getType()==ttype ) {
					j++;
					if ( j == i ) {
						return tnode;
					}
				}
			}
		}

		return null;
	}

	public List<TerminalNode> getTokens(int ttype) {
		if ( children==null ) {
			return Collections.emptyList();
		}

		List<TerminalNode> tokens = null;
		for (ParseTree o : children) {
			if ( o instanceof TerminalNode ) {
				TerminalNode tnode = (TerminalNode)o;
				Token symbol = tnode.getSymbol();
				if ( symbol.getType()==ttype ) {
					if ( tokens==null ) {
						tokens = new ArrayList<TerminalNode>();
					}
					tokens.add(tnode);
				}
			}
		}

		if ( tokens==null ) {
			return Collections.emptyList();
		}

		return tokens;
	}

	public <T extends ParserRuleContext> T getRuleContext(Class<? extends T> ctxType, int i) {
		return getChild(ctxType, i);
	}

	public <T extends ParserRuleContext> List<T> getRuleContexts(Class<? extends T> ctxType) {
		if ( children==null ) {
			return Collections.emptyList();
		}

		List<T> contexts = null;
		for (ParseTree o : children) {
			if ( ctxType.isInstance(o) ) {
				if ( contexts==null ) {
					contexts = new ArrayList<T>();
				}

				contexts.add(ctxType.cast(o));
			}
		}

		if ( contexts==null ) {
			return Collections.emptyList();
		}

		return contexts;
	}

	@Override
	public int getChildCount() { return children!=null ? children.size() : 0; }

	@Override
	public Interval getSourceInterval() {
		if ( start == null ) {
			return Interval.INVALID;
		}
		if ( stop==null || stop.getTokenIndex()<start.getTokenIndex() ) {
			return Interval.of(start.getTokenIndex(), start.getTokenIndex()-1); // empty
		}
		return Interval.of(start.getTokenIndex(), stop.getTokenIndex());
	}

	/**
	 * Get the initial token in this context.
	 * Note that the range from start to stop is inclusive, so for rules that do not consume anything
	 * (for example, zero length or error productions) this token may exceed stop.
	 */
	public Token getStart() { return start; }
	/**
	 * Get the final token in this context.
	 * Note that the range from start to stop is inclusive, so for rules that do not consume anything
	 * (for example, zero length or error productions) this token may precede start.
	 */
	public Token getStop() { return stop; }

	/** Used for rule context info debugging during parse-time, not so much for ATN debugging */
	public String toInfoString(Parser recognizer) {
		List<String> rules = recognizer.getRuleInvocationStack(this);
		Collections.reverse(rules);
		return "ParserRuleContext"+rules+"{" +
			"start=" + start +
			", stop=" + stop +
			'}';
	}
}
