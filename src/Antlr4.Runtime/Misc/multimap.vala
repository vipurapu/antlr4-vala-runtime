/* multimap.vala
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

public class Antlr4.Runtime.Misc.MultiMap<K, V> : Gee.HashMap<K, Gee.List<V>>
{
	public void map(K key, V val)
	{
		Gee.List<V> elements = get(key);
		if (elements == null)
		{
			elements = new Gee.ArrayList<V>();
			base.set(key, elements);
		}
		elements.add(val);
	}

	public Gee.List<Pair<K,V>> get_pairs()
	{
		Gee.List<Pair<K,V>> pairs = new Gee.ArrayList<Pair<K,V>>();
		foreach (K key in keys)
			foreach (V val in get(key))
				pairs.add(new Pair<K,V>(key, val));

		return pairs;
	}
}
