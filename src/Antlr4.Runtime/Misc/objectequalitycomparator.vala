/* objectequalitycomparator.vala
 *
 * Copyright 2020 Valio Valtokari <ubuntugeek1904@gmail.com>
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     <http://www.apache.org/licenses/LICENSE-2.0>
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 * SPDX-License-Identifier: Apache-2.0
 */
/**
 * This default implementation of {@link Antlr4.Runtime.Misc.EqualityComparator} uses object equality
 * for comparisons by calling {@link GLib.direct_hash}.
 *
 * This class is copied from the Java runtime, made compatible with Vala
 */
public class Antlr4.Runtime.Misc.ObjectEqualityComparator : AbstractEqualityComparator<Hashable>
{
	public static ObjectEqualityComparator INSTANCE
	{
	    get;
	    private set;
	    default = new ObjectEqualityComparator();
	}

	/**
	 * {@inheritDoc}
	 *
	 * This implementation uses {@link GLib.direct_hash}
	 * or if obj is a {@link Hashable},
	 */
	public override uint64 hash_code(Hashable obj) {
		if (obj == null)
			return 0;

		return GLib.direct_hash(obj);
	}

	/**
	 * {@inheritDoc}
	 *
	 * This implementation relies on object equality. If both objects are
	 * null, this method returns true. Otherwise if only
	 * a is null, this method returns false. Otherwise,
	 * this method returns the result of
	 * a == b.
	 */
	public override bool equals(Hashable a, Hashable b) {
		if (a == null)
			return b == null;

		return a == b;
	}

}
