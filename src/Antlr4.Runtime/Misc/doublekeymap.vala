/* doublekeymap.vala
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

/**
 * Sometimes we need to map a key to a value but key is two pieces of data.
 * This nested hash table saves creating a single key each time we access
 * map; avoids mem creation.
 *
 * This class is mostly copied from the Java runtime, made compatible with Vala.
 */
public class Antlr4.Runtime.Misc.DoubleKeyMap<K1, K2, V> : GLib.Object
{
    internal Gee.Map<K1, Gee.Map<K2, V>> data
    {
        internal get;
        private set;
        default = new Gee.HashMap<K1, Gee.Map<K2, V>>();
    }

    public new V set(K1 k1, K2 k2, V v)
            requires (k1 is GLib.Object &&
                      k2 is GLib.Object &&
                      v is GLib.Object)
    {
		Gee.Map<K2, V> data2 = data[k1];
		V prev = null;
		if (data2 == null)
		{
			data2 = new Gee.HashMap<K2, V>();
			data[k1] = data2;
		}
		else prev = data2[k2];
		data2[k2] = v;
		return prev;
	}

	public new V get(K1 k1, K2 k2) requires (k1 is GLib.Object &&
	                                         k2 is GLib.Object)
	{
		Gee.Map<K2, V> data2 = data[k1];
		if (data2 == null) return null;
		return data2[k2];
	}

	public Gee.Map<K2, V> get_map(K1 k1)
	{
	    return data[k1];
	}

    /** Get all values associated with primary key */
	public Gee.Collection<V>? values(K1 k1) requires (k1 is GLib.Object)
	{
		Gee.Map<K2, V> data2 = data[k1];
		if (data2 == null) return null;
		return data2.values;
	}

	/** get all primary keys */
	public Gee.Set<K1> key_set()
	{
		return data.keys;
	}

	/** get all secondary keys associated with a primary key */
	public Gee.Set<K2>? key_set_(K1 k1) requires (k1 is GLib.Object)
	{
		Gee.Map<K2, V> data2 = data[k1];
		if (data2 == null) return null;
		return data2.keys;
	}
}
