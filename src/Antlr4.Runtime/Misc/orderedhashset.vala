/* orderedhashset.vala
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
 * A {@link Gee.HashSet} that remembers the order that the elements were added.
 * You can alter the ith element with set(i,value) too :)
 * Unique list.
 *
 * This class is mostly copied from the Java runtime,
 * made compatible with Vala.
 */
public class Antlr4.Runtime.Misc.OrderedHashSet<E> : Gee.HashSet<E>
{
    protected Gee.List<E> items = new Gee.ArrayList<E>();

    /**
     * Returns a {@link Gee.List} containing all the
     * elements on this OrderedHashSet.
     *
     * @return The elements of this OrderedHashSet as a {@link Gee.List}
     */
    public Gee.List<E> elements()
    {
        return new Gee.ArrayList<E>.wrap(to_array());
    }

    /**
     * Returns the item at the specified index.
     *
     * @param index the index
     * @return the item at index
     */
    public new E get(int index)
    {
        return items[index];
    }

    /**
     * Set the item at i to val.
     *
     * @param i the index of the item
     * @param val the new item
     * @return the replaced item
     */
    public new E set(int i, E val) {
        var old_element = items[i];
        items[i] = val;
        base.remove(old_element);
        base.add(val);
        return old_element;
    }

    /**
     * Removes the item at i.
     *
     * @param i the index to
     * remove the item from.
     */
    public new bool remove(int i) {
		var o = items.remove(i);
        return base.remove(o);
	}

    /**
     * Add a value to the list.
     */
	public new bool add(E val) {
        var result = base.add(val);
		if (result)
			items.add(val);
		return result;
    }

    /**
     * Get an iterator for this OrderedHashSet.
     *
     * @return an iterator
     */
    public override Gee.Iterator<E> iterator()
    {
        return items.iterator();
    }

    /**
     * Returns the elements of this OrderedHashSet
     * as an array of type E.
     *
     * @return an array containing type E.
     */
    public E[] to_array()
    {
        return items.to_array();
    }
}
