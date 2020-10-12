/* recognizer.vala
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
using Antlr4.Runtime.Error;
using Antlr4.Runtime.Misc;
using Antlr4.Runtime.Atn;

public abstract class Antlr4.Runtime.Recognizer<Symbol, ATNInterpreter> : GLib.Object
{
	public const int EOF = -1;

	private static Gee.Map<Vocabulary, Gee.Map<string, int>> token_type_map_cache =
		new Gee.HashMap<Vocabulary, Gee.Map<string, int>>();
	private static Gee.Map<Gee.List<string>, Gee.Map<string, int>> rule_index_map_cache =
		new Gee.HashMap<Gee.List<string>, Gee.Map<string, int>>();


	private Gee.List<ANTLRErrorListener> _listeners =
		new Gee.ConcurrentList<ANTLRErrorListener>();

    construct
    {
        _listeners.add(ConsoleErrorListener.INSTANCE);
    }

	protected ATNInterpreter _interp;

	private int _state_number = -1;

	/**
	 * Used to print out token names like ID during debugging and
	 * error reporting.  The generated parsers implement a method
	 * that overrides this to point to their String[] tokenNames.
	 *
	 * @deprecated Use {@link #vocabulary} instead.
	 */
	[Version (deprecated = true, replacement = "vocabulary")]
	public abstract string[] token_names { get; protected set; }

	public abstract string[]? rule_names { get; protected set; }

	/**
	 * The vocabulary used by the recognizer.
	 *
	 * The {@link Vocabulary} instance providing information about the
	 * vocabulary used by the grammar.
	 */
	public Vocabulary vocabulary
	{
	    owned get
	    {
		    return VocabularyImpl.from_token_names(token_names);
		}
	}

	/**
	 * Get a map from token names to token types.
	 *
	 * <p>Used for XPath and tree pattern compilation.</p>
	 */
	public Gee.Map<string, int?> token_type_map
	{
	    get
	    {
		    Vocabulary vocabulary = this.vocabulary;
		    lock (token_type_map_cache)
		    {
			    Gee.Map<string, int?> result = token_type_map_cache[vocabulary];
			    if (result == null)
			    {
				    result = new Gee.HashMap<string, int?>();
				    for (int i = 0; i <= atn.max_token_type; i++)
				    {
				    	string literal_name = vocabulary.get_literal_name(i);
				    	if (literal_name != null)
				    		result[literal_name] = i;

				    	string symbolic_name = vocabulary.get_symbolic_name(i);
				    	if (symbolic_name != null)
				    		result[symbolic_name] = i;
				    }

				    result["EOF"] = Token.EOF;
			       	result = result.read_only_view;
			       	token_type_map_cache[vocabulary] = result;
			    }

		    	return result as unowned Gee.Map<string, int?>;
		    }
		}
	}

	/**
	 * Get a map from rule names to rule indexes.
	 *
	 * <p>Used for XPath and tree pattern compilation.</p>
	 */
	public Gee.Map<string, int> rule_index_map
	{
	    owned get
	    {
		    string[]? rule_names = rule_names;
		    if (rule_names == null)
			    throw new StateError.ILLEGAL_STATE("The current recognizer does not provide a list of rule names.");

		    lock (rule_index_map_cache)
		    {
			    var result = rule_index_map_cache[new Gee.ArrayList<string>.wrap(rule_names)];
			    if (result == null)
			    {
				    result = Util.to_map(rule_names).read_only_view;
				    rule_index_map_cache[new Gee.ArrayList<string>.wrap(rule_names)] = result;
			    }

			    return result;
		    }
		}
	}

	public int get_token_type(string name)
	{
		int? ttype = token_type_map[name];
		if (ttype != null) return ttype;
		return Token.INVALID_TYPE;
	}

	/**
	 * If this recognizer was generated, it will have a serialized ATN
	 * representation of the grammar.
	 *
	 * <p>For interpreters, we don't know their serialized ATN despite having
	 * created the interpreter from it.</p>
	 */
	public string serialized_atn
	{
	    get
	    {
		    throw new StateError.ILLEGAL_STATE("there is no serialized ATN");
		}
	}

	/**
	 * For debugging and other purposes, might want the grammar name.
	 * Have ANTLR generate an implementation for this method.
	 */
	public abstract string grammar_file_name { get; protected set; }

	/**
	 * Get the {@link ATN} used by the recognizer for prediction.
	 *
	 * @return The {@link ATN} used by the recognizer for prediction.
	 */
	public abstract ATN atn { get; protected set; }

	/**
	 * The ATN interpreter used by the recognizer for prediction.
	 */
	public ATNInterpreter interpreter { get; set; }

	/**
	 * If profiling during the parse/lex, this will return DecisionInfo records
	 * for each decision in recognizer in a ParseInfo object.
	 *
	 * @since 4.3
	 */
	[Version (since = "4.3")]
	public ParseInfo? parse_info
	{
	    get
	    {
		    return null;
		}
	}

	/** What is the error header, normally line/character position information? */
	public string get_error_header(RecognitionError e)
	{
		int line = e.offending_token.line;
		int char_position_in_line = e.offending_token.char_position_in_line;
		return "line %d:%d".printf(line, char_position_in_line);
	}

	/**
	 * How should a token be displayed in an error message? The default
	 * is to display just the text, but during development you might
	 * want to have a lot of information spit out.  Override in that case
	 * to use t.toString() (which, for CommonToken, dumps everything about
	 * the token). This is better than forcing you to override a method in
	 * your token objects because you don't have to go modify your lexer
	 * so that it creates a new Java type.
	 *
	 * @deprecated This method is not called by the ANTLR 4 Runtime. Specific
	 * implementations of {@link ANTLRErrorStrategy} may provide a similar
	 * feature when necessary. For example, see
	 * {@link DefaultErrorStrategy#getTokenErrorDisplay}.
	 */
	[Version (deprecated = true)]
	public string get_token_error_display(Token? t)
	{
		if (t == null) return "<no token>";
		string? s = t.text;
		if (s == null)
		{
			if (t.type == Token.EOF)
				s = "<EOF>";

			else s = "<%d>".printf(t.type);
		}
		s = s.replace("\n","\\n");
		s = s.replace("\r","\\r");
		s = s.replace("\t","\\t");
		return "'%s'".printf(s ?? "");
	}

	public void add_error_listener(ANTLRErrorListener listener)
	{
		_listeners.add(listener);
	}

	public void remove_error_listener(ANTLRErrorListener listener)
	{
		_listeners.remove(listener);
	}

	public void remove_error_listeners()
	{
		_listeners.clear();
	}


	public Gee.List<ANTLRErrorListener> error_listeners
	{
	    get
	    {
		    return _listeners;
		}
	}

	public ANTLRErrorListener error_listener_dispatch
	{
	    get
	    {
		    return new ProxyErrorListener(error_listeners);
		}
	}

	// subclass needs to override these if there are sempreds or actions
	// that the ATN interp needs to execute
	public bool sempred(RuleContext _localctx, int rule_index, int action_index)
	{
		return true;
	}

	public bool precpred(RuleContext localctx, int precedence)
	{
		return true;
	}

	public void action(RuleContext _localctx, int ruleIndex, int actionIndex) {  }

	public sealed int state
	{
	    get
	    {
		    return _state_number;
		}
		set
		{
		    _state_number = value;
		}
	}

	public abstract IntStream input_stream { get; set; }

	public abstract TokenFactory token_factory { get; set; }
}
