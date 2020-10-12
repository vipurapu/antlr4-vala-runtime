/* flexiblehashmap.vala
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
 * A limited map (many unsupported operations) that lets me use
 * varying hashCode/equals.
 */
public class Antlr4.Runtime.Misc.FlexibleHashMap<K, V> : GLib.Object, Gee.Map<K, V>, Gee.Traversable<K>, Gee.Iterable<K>, Hashable
{
	public const int INITAL_CAPACITY = 16; // must be power of 2
	public const int INITAL_BUCKET_CAPACITY = 8;
	public const double LOAD_FACTOR = 0.75;

	public class Entry<K, V> : GLib.Object
	{
		public K key { get; private set; }
		public V val;

		public Entry(K key, V val) requires (key is GLib.Object && val is GLib.Object)
		{
		    this.key = key;
		    this.val = val;
		}

		public string to_string ()
	    {
		    return "Entry object at %p".printf (&this);
		}
	}


	protected AbstractEqualityComparator<K>? comparator;

	protected Gee.LinkedList<Entry<K, V>>[] buckets;

	/** How many elements in set */
	protected int n = 0;

	protected int threshold = (int)(INITAL_CAPACITY * LOAD_FACTOR); // when to expand

	protected int current_prime = 1; // jump by 4 primes each expand or whatever
	protected int initial_bucket_capacity = INITAL_BUCKET_CAPACITY;

	public FlexibleHashMap(AbstractEqualityComparator<K>?    comparator = null,
	                       int                               initial_capacity = INITAL_CAPACITY,
	                       int                               initial_bucket_capacity = INITAL_BUCKET_CAPACITY)
    {
		this.comparator = comparator ?? ObjectEqualityComparator.INSTANCE;
		this.buckets = new Gee.LinkedList<Entry<K, V>>[initial_bucket_capacity];
		this.initial_bucket_capacity = initial_bucket_capacity;
	}

	protected uint64 get_bucket(K key) requires (key is GLib.Object)
	{
		var hash = comparator.hash_code(key);
		var b = hash & (buckets.length - 1);
		return b;
	}

	public new V get(K key) requires (key is GLib.Object)
	{
		if (key == null) return null;
		var b = get_bucket(key);
		var bucket = buckets[b];
		if (bucket == null) return null; // no bucket
		foreach (Entry<K, V> e in bucket)
		{
			if (comparator.equals(e.key, key))
			return e.val;

		}
		return null;
	}

	public override void set(K key, V val) requires (key is GLib.Object && val is GLib.Object)
	{
		if (key == null) return;
		if (n > threshold) expand();
		var b = get_bucket(key);
		var bucket = buckets[b];
		if (bucket == null)
			bucket = buckets[b] = new Gee.LinkedList<Entry<K, V>>();

		foreach (Entry<K, V> e in bucket)
		{
			if (comparator.equals(e.key, key))
			{
				V prev = e.val;
				e.val = val;
				n++;
				break;
			}
		}
		// not there
		bucket.add(new Entry<K, V>(key, val));
		n++;
	}

    public override bool unset (K key, out V value = null)
    {
        return false;
    }

	public override Gee.Collection<V> values
	{
	    owned get
	    {
		    Gee.List<V> a = new Gee.ArrayList<V>();
		    foreach (var bucket in buckets)
		    {
			    if (bucket == null) continue;
			    foreach (var e in bucket)
			    	a.add(e.val);
		    }
		    return a;
		}
	}

	public override Gee.Set<Gee.Map.Entry<K, V>> entries
	{
	    owned get
	    {
	        return null;
	    }
	}

	public override Gee.Set<K> keys
	{
	    owned get
	    {
	        return null;
	    }
	}

	public override bool read_only { get { return false; } }

	public override Gee.Map<K, V> read_only_view
	{
	    owned get
	    {
	        return null;
	    }
	}

	public override int size
	{
	    get
	    {
	        return n;
	    }
	}

	public override bool foreach(Gee.ForallFunc<K> f)
	{
		return false;
	}

	public override Gee.Iterator<Gee.Map.Entry<K, V>> iterator()
	{
	    return null;
	}

	public bool contains_key(GLib.Object key) requires (key is GLib.Object)
	{
		return get(key) != null;
	}

	public override uint64 hash_code()
	{
		var hash = MurmurHash.initialize();
		foreach (var bucket in buckets)
		{
			if (bucket == null) continue;
			foreach (var e in bucket)
			{
				if (e == null) break;
				hash = MurmurHash.update(hash, (int64) comparator.hash_code(e.key));
			}
		}

		hash = MurmurHash.finish(hash, size);
		return hash;
	}

	protected void expand()
	{
		Gee.LinkedList<Entry<K, V>>[] old = buckets;
		current_prime += 4;
		int new_capacity = buckets.length * 2;
		Gee.LinkedList<Entry<K, V>>[] new_table = new Gee.LinkedList<Entry<K, V>>[new_capacity];
		buckets = new_table;
		threshold = (int)(new_capacity * LOAD_FACTOR);

		int old_size = size;
		foreach (var bucket in old)
	    {
			if (bucket == null) continue;
			foreach (var e in bucket)
	        {
				if (e == null) break;
				set(e.key, e.val);
			}
		}
		n = old_size;
	}

	public bool is_empty {
	    get
	    {
		    return n == 0;
		}
	}

	public override bool has (K key, V value)
	{
        return false;
	}

	public override bool has_key (K key)
	{
	    return false;
	}

	public override Gee.MapIterator<K, V> map_iterator ()
	{
	    return null;
	}

	public void clear()
	{
		buckets = new Gee.LinkedList<Entry<K, V>>[INITAL_CAPACITY];
		n = 0;
	}

	public string to_string()
	{
		if (size == 0) return "{}";

		StringBuilder buf = new StringBuilder();
		buf.append_c('{');
		bool first = true;
		foreach (var bucket in buckets)
	    {
			if (bucket == null) continue;
			foreach (Entry<K, V> e in bucket)
	        {
				if (e == null) break;
				if (first) first = false;
				else buf.append(", ");
				buf.append(e.to_string());
			}
		}
		buf.append_c('}');
		return buf.str;
	}

	public string to_table_string()
	{
		StringBuilder buf = new StringBuilder();
		foreach (var bucket in buckets)
	    {
			if (bucket == null)
	        {
				buf.append("null\n");
				continue;
			}
			buf.append_c('[');
			bool first = true;
			foreach (var e in bucket)
	        {
				if (first) first = false;
				else buf.append(" ");
				if (e == null) buf.append("_");
				else buf.append(e.to_string());
			}
			buf.append("]\n");
		}
		return buf.str;
	}
}
