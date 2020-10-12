/* interval.vala
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

public class Antlr4.Runtime.Misc.Interval : GLib.Object, Hashable
{
	public const int INTERVAL_POOL_MAX_VALUE = 1000;
	public Interval INVALID { get; default = new Interval(-1,-2); }

	internal static Interval[] cache = new Interval[INTERVAL_POOL_MAX_VALUE + 1];

	public int a;
	public int b;

	public static int creates = 0;
	public static int misses = 0;
	public static int hits = 0;
	public static int out_of_range = 0;

	public Interval(int a, int b)
	{
	    this.a = a;
	    this.b = b;
	}

	/**
	 * Interval objects are used readonly so share all with the
	 * same single value a==b up to some max size.  Use an array as a perfect hash.
	 * Return shared object for 0..INTERVAL_POOL_MAX_VALUE or a new
	 * Interval object with a..a in it.  On Java.g4, 218623 IntervalSets
	 * have a..a (set with 1 element).
	 */
	public static Interval of(int a, int b)
	{
		// cache just a..a
		if ( a != b || a < 0 || a > INTERVAL_POOL_MAX_VALUE )
			return new Interval(a,b);
		if (cache[a] == null)
			cache[a] = new Interval(a,a);

		return cache[a];
	}

	/**
	 * Return the number of elements between a and b inclusively. x..x is length 1.
	 * if b &lt; a, then length is 0.  9..10 has length 2.
	 */
	public int length
	{
	    get
	    {
		    if (b < a) return 0;
		    return b - a + 1;
		}
	}

	public bool equals(Interval i)
	{
		if (i == null)
			return false;

		return this.a == i.a && this.b == i.b;
	}

	public override uint64 hash_code()
	{
		uint64 hash = 23;
		hash = hash * 31 + a;
		hash = hash * 31 + b;
		return hash;
	}

	/** Does this start completely before other? Disjoint */
	public bool starts_before_disjoint(Interval other)
	{
		return this.a < other.a && this.b < other.a;
	}

	/** Does this start at or before other? Nondisjoint */
	public bool starts_before_non_disjoint(Interval other)
	{
		return this.a <= other.a && this.b >= other.a;
	}

	/** Does this.a start after other.b? May or may not be disjoint */
	public bool starts_after(Interval other)
	{
	    return this.a > other.a;
	}

	/** Does this start completely after other? Disjoint */
	public bool starts_after_disjsoint(Interval other) {
		return this.a > other.b;
	}

	/** Does this start after other? NonDisjoint */
	public bool starts_after_non_disjoint(Interval other)
	{
		return this.a > other.a && this.a <= other.b; // this.b>=other.b implied
	}

	/** Are both ranges disjoint? I.e., no overlap? */
	public bool disjoint(Interval other)
	{
		return starts_before_disjoint(other) || starts_after_disjsoint(other);
	}

	/** Are two intervals adjacent such as 0..41 and 42..42? */
	public bool adjacent(Interval other)
	{
		return this.a == other.b + 1 || this.b == other.a - 1;
	}

	public bool properly_contains(Interval other)
	{
		return other.a >= this.a && other.b <= this.b;
	}

	/** Return the interval computed from combining this and other */
	public Interval union(Interval other)
	{
		return Interval.of(Util.min(a, other.a), Util.max(b, other.b));
	}

	/** Return the interval in common between this and o */
	public Interval intersection(Interval other)
	{
		return Interval.of(Util.max(a, other.a), Util.min(b, other.b));
	}

	/**
	 * Return the interval with elements from this not in other;
	 * other must not be totally enclosed (properly contained)
	 * within this, which would result in two disjoint intervals
	 * instead of the single one returned by this method.
	 */
	public Interval difference_not_properly_contained(Interval other)
	{
		Interval diff = null;
		// other.a to left of this.a (or same)
		if (other.starts_before_non_disjoint(this))
			diff = Interval.of(Util.max(this.a, other.b + 1),
							   this.b);

		// other.a to right of this.a
		else if (other.starts_after_non_disjoint(this))
			diff = Interval.of(this.a, other.a - 1);

		return diff;
	}

	public string to_string()
	{
		return a.to_string() + ".." + b.to_string();
	}
}
