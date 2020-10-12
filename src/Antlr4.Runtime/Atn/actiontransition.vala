/* actiontransition.vala
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


public class Antlr4.Runtime.Atn.ActionTransition : Transition
{
	public int rule_index { get; construct; }
	public int action_index { get; construct; }
	public bool is_ctx_dependent { get; construct; } // e.g., $i ref in action

	public ActionTransition(ATNState target, int rule_index, int action_index = -1, boolean is_ctx_dependent = false)
	{
		base(target);
		Object(
		    rule_index: rule_index,
		    action_index: action_index,
		    is_ctx_dependent: is_ctx_dependent
	    );
	}

	public int serialization_type
	{
	    get
	    {
		    return ACTION;
		}
	}

	public override bool is_epsilon
	{
	    get
	    {
		    return true; // we are to be ignored by analysis 'cept for predicates
		}
	}

	public bool matches(int symbol, int min_vocab_symbol, int max_vocab_symbol)
	{
		return false;
	}

	public string to_string()
	{
		return "action_%d:%d".printf(rule_index, action_index);
	}
}
