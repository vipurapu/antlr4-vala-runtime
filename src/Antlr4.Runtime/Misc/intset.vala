/* intset.vala
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
using Antlr4.Runtime.Error;

/**
 * A generic set of integers.
 *
 * @see IntervalSet
 */
public interface Antlr4.Runtime.Misc.IntSet : GLib.Object
{
	/**
	 * Adds the specified value to the current set.
	 *
	 * @param el the value to add
	 *
	 * @throws IllegalStateException if the current set is read-only
	 */
	public abstract void add(int el) throws StateError;

	/**
	 * Modify the current {@link IntSet} object to contain all elements that are
	 * present in itself, the specified set, or both.
	 *
	 * @param _set The set to add to the current set. A null argument is
	 * treated as though it were an empty set.
	 * @return this (to support chained calls)
	 *
	 * @throws StateError if the current set is read-only
	 */

	public abstract IntSet add_all(IntSet _set) throws StateError;

	/**
	 * Return a new {@link IntSet} object containing all elements that are
	 * present in both the current set and the specified set a.
	 *
	 * @param a The set to intersect with the current set. A  null
	 * argument is treated as though it were an empty set.
	 * @return A new {@link IntSet} instance containing the intersection of the
	 * current set and a. The value null may be returned in
	 * place of an empty result set.
	 */

	public abstract IntSet? and(IntSet a);

	/**
	 * Return a new {@link IntSet} object containing all elements that are
	 * present in  elements} but not present in the current set. The
	 * following expressions are equivalent for input non-null {@link IntSet}
	 * instances  x} and  y}.
	 *
	 * <ul>
	 * <li> x.complement(y)}</li>
	 * <li> y.subtract(x)}</li>
	 * </ul>
	 *
	 * @param elements The set to compare with the current set. A  null
	 * argument is treated as though it were an empty set.
	 * @return A new {@link IntSet} instance containing the elements present in
	 * elements but not present in the current set. The value
	 * null may be returned in place of an empty result set.
	 */

	public abstract IntSet? complement(IntSet elements);

	/**
	 * Return a new {@link IntSet} object containing all elements that are
	 * present in the current set, the specified set  a}, or both.
	 *
	 * <p>
	 * This method is similar to {@link #addAll(IntSet)}, but returns a new
	 * {@link IntSet} instance instead of modifying the current set.</p>
	 *
	 * @param a The set to union with the current set. A null argument
	 * is treated as though it were an empty set.
	 * @return A new {@link IntSet} instance containing the union of the current
	 * set and a. The value null may be returned in place of an
	 * empty result set.
	 */

	public abstract IntSet or(IntSet a);

	/**
	 * Return a new {@link IntSet} object containing all elements that are
	 * present in the current set but not present in the input set  a}.
	 * The following expressions are equivalent for input non-null
	 * {@link IntSet} instances x and y.
	 *
	 * <ul>
	 * <li> y.subtract(x)}</li>
	 * <li> x.complement(y)}</li>
	 * </ul>
	 *
	 * @param a The set to compare with the current set. A null
	 * argument is treated as though it were an empty set.
	 * @return A new {@link IntSet} instance containing the elements present in
	 *  elements} but not present in the current set. The value
	 * null may be returned in place of an empty result set.
	 */

	public abstract IntSet subtract(IntSet a);

	/**
	 * Return the total number of elements represented by the current set.
	 *
	 * @return the total number of elements represented by the current set,
	 * regardless of the manner in which the elements are stored.
	 */
	public abstract int size();

	/**
	 * Returns true if this set contains no elements.
	 *
	 * @return true if the current set contains no elements; otherwise,
	 * false.
	 */
	public abstract bool is_nil();

	/**
	 * Returns whether this and i are equal
	 *
	 * @param i the other IntSet
	 */
	public abstract bool equals(IntSet i);

	/**
	 * Returns true if the set contains the specified element.
	 *
	 * @param el The element to check for.
	 * @return true if the set contains el; otherwise  false.
	 */
	public abstract bool contains(int el);

	/**
	 * Removes the specified value from the current set. If the current set does
	 * not contain the element, no changes are made.
	 *
	 * @param el the value to remove
	 *
	 * @exception IllegalStateException if the current set is read-only
	 */
	public abstract void remove(int el) throws StateError;

	/**
	 * Return a list containing the elements represented by the current set. The
	 * list is returned in ascending numerical order.
	 *
	 * @return A list containing all element present in the current set, sorted
	 * in ascending numerical order.
	 */

	public abstract Gee.List<int> to_list();

	/**
	 * Returns a string representation of this IntSet
	 */
	public abstract string to_string(bool elem_are_char = false);
}
