/* pair.vala
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

public class Antlr4.Runtime.Misc.Pair<A,B> : GLib.Object, Hashable
{
	public A a { get; construct; }
	public B b { get; construct; }

	public Pair(A _a, B _b) requires (_a is Hashable && _b is Hashable)
	{
		Object (a: _a, b: _b);
	}

	public bool equals(Pair obj) {
		if (obj == this)
			return true;

		else if (!(obj is Pair))
			return false;

		Pair<A, B> other = (Pair<A, B>) obj;
		return ObjectEqualityComparator.INSTANCE.equals(a as Hashable, other.a as Hashable)
			&& ObjectEqualityComparator.INSTANCE.equals(b as Hashable, other.b as Hashable);
	}

	public override uint64 hash_code()
	{
        var hash = MurmurHash.initialize();
		hash = MurmurHash._update(hash, a as Hashable);
		hash = MurmurHash._update(hash, b as Hashable);
		return MurmurHash.finish(hash, 2);
	}
}
