/* triple.vala
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
using Antlr4.Runtime;

public class Antlr4.Runtime.Misc.Triple<A, B, C> : GLib.Object, Hashable
{
	public A a { get; construct; }
	public B b { get; construct; }
	public C c { get; construct; }

	public Triple(A _a, B _b, C _c) requires (_a is Hashable &&
	                                          _b is Hashable &&
	                                          _c is Hashable)
	{
		Object (a: _a, b: _b, c: _c);
	}

	public bool equals(Triple<A, B, C> obj)
	{
		if (obj == this)
			return true;

		return ObjectEqualityComparator.INSTANCE.equals(a as Hashable, obj.a as Hashable)
			&& ObjectEqualityComparator.INSTANCE.equals(b as Hashable, obj.b as Hashable)
			&& ObjectEqualityComparator.INSTANCE.equals(c as Hashable, obj.c as Hashable);
	}

	public override uint64 hash_code()
	{
		var hash = MurmurHash.initialize();
		hash = MurmurHash._update(hash, a as Hashable);
		hash = MurmurHash._update(hash, b as Hashable);
		hash = MurmurHash._update(hash, c as Hashable);
		return MurmurHash.finish(hash, 3);
	}

	public string to_string()
	{
		return "(%p, %p, %p)".printf(a, b, c);
	}
}
