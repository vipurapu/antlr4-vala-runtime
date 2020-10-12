/* arraypredictioncontext.vala
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

public class Antlr4.Runtime.Atn.ArrayPredictionContext : PredictionContext
{
	/**
	 * Parent can be null only if full ctx mode and we make an array
	 * from {@link #EMPTY} and non-empty. We merge {@link #EMPTY} by using null parent and
	 * return_state == {@link #EMPTY_RETURN_STATE}.
	 */
	public PredictionContext?[] parents { get; protected set; }

	/**
	 * Sorted for merge, no duplicates; if present,
	 * {@link #EMPTY_RETURN_STATE} is always last.
 	 */
	public int[] return_states { get; protected set; }

	public ArrayPredictionContext(SingletonPredictionContext a)
	{
		this.from_scratch(new PredictionContext[] { a.parent }, new int[] { a.return_state });
	}

	public ArrayPredictionContext.from_scratch(PredictionContext[] parents, int[] return_states)
	{
		base(calculateHashCode(parents, return_states));
		assert parents!=null && parents.length>0;
		assert return_states!=null && return_states.length>0;
//		System.err.println("CREATE ARRAY: "+Arrays.toString(parents)+", "+Arrays.toString(return_states));
		this.parents = parents;
		this.return_states = return_states;
	}

	public bool is_empty
	{
	    get
	    {
		    // since EMPTY_RETURN_STATE can only appear in the last position, we
		    // don't need to verify that size==1
		    return return_states[0] == EMPTY_RETURN_STATE;
	    }
	}

	public int size
	{
	    get
	    {
		    return return_states.length;
		}
	}

	public override PredictionContext? get_parent_at(uint index)
	{
		return parents[index];
	}

	public override int get_return_state_at(uint index)
	{
		return return_states[index];
	}

	public bool equals(ArrayPredictionContext o)
	{
		if (this == o)
			return true;

		if (this.hash_code() != o.hash_code())
			return false; // can't be same if hash is different

		return Util.array_equals(return_states, o.return_states) &&
		       Util.array_equals(parents, o.parents);
	}

	public string to_string()
	{
		if (is_empty) return "[]";
		StringBuilder buf = new StringBuilder();
		buf.append("[");
		for (int i = 0; i < return_states.length; i++)
		{
			if (i > 0) buf.append(", ");
			if (return_states[i] == EMPTY_RETURN_STATE)
			{
				buf.append("$");
				continue;
			}
			buf.append(return_states[i]);
			if (parents[i] != null)
			{
				buf.append_c(' ');
				buf.append(parents[i].to_string());
			}
			else buf.append("null");
		}
		buf.append("]");
		return buf.str;
	}
}
