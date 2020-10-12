/* integerstack.vala
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

public class Antlr4.Runtime.Misc.IntegerStack : IntegerList
{

	public IntegerStack(int capacity = 0)
	{
	    base(capacity);
	}

	public IntegerStack.dup(IntegerStack list)
	{
		base.dup(list);
	}

	public sealed void push(int value)
	{
		add(value);
	}

	public sealed int pop()
	{
		return remove_at(size - 1);
	}

	public sealed int peek()
	{
		return get(size - 1);
	}

}
