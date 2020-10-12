/* intervalset.vala
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
using Antlr4.Runtime.Error;

/**
 * This class implements the {@link IntSet} backed by a sorted array of
 * non-overlapping intervals. It is particularly efficient for representing
 * large collections of numbers, where the majority of elements appear as part
 * of a sequential range of numbers that are all part of the set. For example,
 * the set { 1, 2, 3, 4, 7, 8 } may be represented as { [1, 4], [7, 8] }.
 *
 * <p>
 * This class is able to represent sets containing any combination of values in
 * the range {@link Integer#MIN_VALUE} to {@link Integer#MAX_VALUE}
 * (inclusive).</p>
 */
public class Antlr4.Runtime.Misc.IntervalSet : GLib.Object, IntSet, Hashable
{
	public static IntervalSet COMPLETE_CHAR_SET { get; default = IntervalSet.of(Lexer.MIN_CHAR_VALUE, Lexer.MAX_CHAR_VALUE); }

	static construct
	{
		COMPLETE_CHAR_SET.readonly = true;
		EMPTY_SET.readonly = true;
	}

	public static IntervalSet EMPTY_SET { get; default = new IntervalSet(); }

	/** The list of sorted, disjoint intervals. */
    public Gee.ArrayList<Interval> intervals { get; private set; }

    public bool readonly
    {
        get
        {
            return readonly;
        }

        set
        {
            verify_alter();
            this.readonly = readonly;
        }
    }

    private void verify_alter() throws StateError
    {
        if (readonly)
            throw new StateError.ILLEGAL_STATE("can't alter readonly IntervalSet");
    }

	public IntervalSet(Gee.ArrayList<Interval> intervals)
	{
		this.intervals = intervals;
	}

	public IntervalSet.copy(IntervalSet set)
	{
		this.array({});
		add_all(set);
	}

	public IntervalSet.array(int[] els)
	{
	    if (els == null || els.length == 0)
	        intervals = new Gee.ArrayList<Interval>();
		Interval[] i = new Interval[els.length];

	}

	/** Create a set with a single element, el. */

    public static IntervalSet of(int a)
    {
		IntervalSet s = new IntervalSet();
        s.add(a);
        return s;
    }

    /** Create a set with all ints within range [a..b] (inclusive) */
	public static IntervalSet of_range(int a, int b)
	{
		IntervalSet s = new IntervalSet();
		s.add_range(a, b);
		return s;
	}

	public void clear() throws StateError
	{
        verify_alter();
		intervals.clear();
	}

    /**
     * Add a single element to the set. An isolated element is stored
     * as a range el..el.
     */
    public void add(int el) throws StateError
    {
        verify_alter();
        add_range(el, el);
    }

    /**
     * Add interval; i.e., add all integers from a to b to set.
     * If b&lt;a, do nothing.
     * Keep list in sorted order (by left range value).
     * If overlap, combine ranges.  For example,
     * If this is {1..5, 10..20}, adding 6..7 yields
     * {1..5, 6..7, 10..20}.  Adding 4..8 yields {1..8, 10..20}.
     */
    public void add_range(int a, int b) throws StateError
    {
        add0(Interval.of(a, b));
    }

	// copy on write so we can cache a..a intervals and sets of that
	protected void add0(Interval addition) throws StateError
	{
        verify_alter();
		if (addition.b < addition.a)
			return;
		// find position in list
		// Use iterators as we modify list in place
		for (var iter = intervals.bidir_list_iterator(); iter.has_next(); iter.next())
		{
			var r = iter.get();
			if (addition.equals(r))
				return;
			if (addition.adjacent(r) || !addition.disjoint(r))
			{
				// next to each other, make a single larger interval
				var bigger = addition.union(r);
				(iter as Gee.ListIterator).set(bigger);
				// make sure we didn't just create an interval that
				// should be merged with next interval in list
				while (iter.has_next())
				{
					var next = iter.get();
					iter.next();
					if (!bigger.adjacent(next) && bigger.disjoint(next))
						break;

					// if we bump up against or overlap next, merge
					iter.remove();   // remove this one
					iter.previous(); // move backwards to what we just set
					// Gee.BidirListIterator inherits from Gee.ListIterator.
					(iter as Gee.ListIterator).set(bigger.union(next)); // set to 3 merged ones
					iter.next(); // first call to next after previous duplicates the result
				}
				return;
			}
			if (addition.starts_before_disjoint(r))
			{
				// insert before r
				iter.previous();
				iter.add(addition);
				return;
			}
			// if disjoint and after r, a future iteration will handle it
		}
		// ok, must be after last interval (and disjoint from last interval)
		// just add it
		intervals.add(addition);
	}

	public IntervalSet add_all_intset(IntSet set) throws StateError
	{
		if (set == null)
			return this;

		if (set is IntervalSet)
		{
			IntervalSet other = set as IntervalSet;
			// walk set and add each interval
			int n = other.intervals.size;
			for (int i = 0; i < n; i++)
			{
				Interval I = other.intervals.get(i);
				this.add_range(I.a, I.b);
			}
		}
		else
		{
			foreach (int value in set.to_list())
				add(value);
		}

		return this;
    }

    public IntervalSet complement_el(int min_element, int max_element)
    {
        return this.complement(IntervalSet.of(min_element, max_element));
    }

    public IntSet? complement(IntSet vocabulary)
    {
		if (vocabulary == null || vocabulary.is_nil())
			return null; // nothing in common with null set

		IntervalSet vocabulary_is;
		if (vocabulary is IntervalSet)
			vocabulary_is = vocabulary as IntervalSet;

		else {
			vocabulary_is = new IntervalSet();
			vocabulary_is.add_all(vocabulary);
		}

		return vocabulary_is.subtract(this);
    }

	public IntSet subtract(IntSet a)
	{
		if (a == null || a.is_nil())
			return new IntervalSet(this);

		if (a is IntervalSet)
			return subtract_lr(this, a as IntervalSet);

		IntervalSet other = new IntervalSet();
		other.add_all(a);
		return subtract_lr(this, other);
	}

	/**
	 * Compute the set difference between two interval sets. The specific
	 * operation is {@code left - right}. If either of the input sets is
	 * {@code null}, it is treated as though it was an empty set.
	 */
	public static IntervalSet subtract_lr(IntervalSet left, IntervalSet right)
	{
		if (left == null || left.is_nil())
			return new IntervalSet();

		IntervalSet result = new IntervalSet(left);
		if (right == null || right.is_nil())
			// right set has no elements; just return the copy of the current set
			return result;

		int result_i = 0;
		int right_i = 0;
		while (result_i < result.intervals.size && right_i < right.intervals.size)
		{
			Interval result_interval = result.intervals[result_i];
			Interval right_interval = right.intervals[right_i];

			// operation: (result_interval - right_interval) and update indexes

			if (right_interval.b < result_interval.a)
		    {
				right_i++;
				continue;
			}

			if (right_interval.a > result_interval.b)
		    {
				result_i++;
				continue;
			}

			Interval before_current = null;
			Interval after_current = null;
			if (right_interval.a > result_interval.a)
				before_current = new Interval(result_interval.a, right_interval.a - 1);


			if (right_interval.b < result_interval.b)
				after_current = new Interval(right_interval.b + 1, result_interval.b);

			if (before_current != null)
				if (after_current != null)
                {
					// split the current interval into two
					result.intervals.set(resultI, before_current);
					result.intervals.add(resultI + 1, after_current);
					result_i++;
					right_i++;
					continue;
				}
				else
				{
					// replace the current interval
					result.intervals.set(resultI, before_current);
					result_i++;
					continue;
				}
			else
			{
				if (after_current != null)
		        {
					// replace the current interval
					result.intervals.set(resultI, after_current);
					right_i++;
					continue;
				}
				else
				{
					// remove the current interval (thus no need to increment resultI)
					result.intervals.remove(resultI);
					continue;
				}
			}
		}

		// If rightI reached right.intervals.size, no more intervals to subtract from result.
		// If resultI reached result.intervals.size, we would be subtracting from an empty set.
		// Either way, we are done.
		return result;
	}

    /** combine all sets in the array returned the or'd value */
	public static IntervalSet or_arr(IntervalSet[] sets)
	{
		IntervalSet r = new IntervalSet();
		foreach (IntervalSet s in sets) r.add_all(s);
		return r;
	}

	public IntSet or(IntSet a)
	{
		IntervalSet o = new IntervalSet();
		o.add_all(this);
		o.add_all(a);
		return o;
	}

    /** {@inheritDoc} */
	public IntSet? and(IntSet other)
	{
		if (other == null)
			return null; // nothing in common with null set

		Gee.List<Interval> my_intervals = this.intervals;
		Gee.List<Interval> their_intervals = (other as IntervalSet).intervals;
		IntervalSet intersection = null;
		int my_size = my_intervals.size;
		int their_size = their_intervals.size;
		int i = 0;
		int j = 0;
		// iterate down both interval lists looking for nondisjoint intervals
		while (i < my_size && j < their_size)
		{
			Interval mine = my_intervals[i];
			Interval theirs = their_intervals[j];
			if (mine.starts_before_disjoint(theirs))
				// move this iterator looking for interval that might overlap
				i++;
			else if (theirs.starts_before_disjoint(mine))
				// move other iterator looking for interval that might overlap
				j++;
			else if (mine.properly_contains(theirs))
		    {
				// overlap, add intersection, get next theirs
				if (intersection == null)
					intersection = new IntervalSet();

				intersection.add(mine.intersection(theirs));
				j++;
			}
			else if (theirs.properly_contains(mine))
		    {
				// overlap, add intersection, get next mine
				if (intersection == null)
					intersection = new IntervalSet();

				intersection.add(mine.intersection(theirs));
				i++;
			}
			else if (!mine.disjoint(theirs))
		    {
				// overlap, add intersection
				if (intersection==null)
					intersection = new IntervalSet();
				intersection.add(mine.intersection(theirs));
				// Move the iterator of lower range [a..b], but not
				// the upper range as it may contain elements that will collide
				// with the next iterator. So, if mine=[0..115] and
				// theirs=[115..200], then intersection is 115 and move mine
				// but not theirs as theirs may collide with the next range
				// in thisIter.
				// move both iterators to next ranges
				if (mine.starts_after_non_disjoint(theirs))
					j++;

				else if (theirs.starts_after_non_disjoint(mine))
					i++;
			}
		}
		if (intersection == null)
			return new IntervalSet();
		return intersection;
	}

    /** {@inheritDoc} */
    public bool contains(int el)
	{
		int n = intervals.size;
		int l = 0;
		int r = n - 1;
		// Binary search for the element in the (sorted,
		// disjoint) array of intervals.
		while (l <= r)
		{
			int m = (l + r) / 2;
			Interval I = intervals.get(m);
			int a = I.a;
			int b = I.b;
			if (b < el)
				l = m + 1;
			else if (a>el )
				r = m - 1;
			else return true;
		}
		return false;
    }

    /** {@inheritDoc} */
    public bool is_nil()
	{
        return intervals == null || intervals.is_empty;
    }

	/**
	 * Returns the maximum value contained in the set if not is_nil().
	 *
	 * @return the maximum value contained in the set.
	 * @throws RuntimeError if set is empty
	 */
	public int get_max_element() throws RuntimeError
	{
		if (is_nil())
			throw new RuntimeError.ERROR("set is empty");

		Interval last = intervals[intervals.size - 1];
		return last.b;
	}

	/**
	 * Returns the minimum value contained in the set if not is_nil().
	 *
	 * @return the minimum value contained in the set.
	 * @throws RuntimeError if set is empty
	 */
	public int get_min_element() throws RuntimeError
	{
		if (is_nil() )
			throw new RuntimeError.ERROR("set is empty");

		return intervals[0].a;
	}

	public uint64 hash_code()
	{
		var hash = MurmurHash.initialize();
		foreach (Interval I in intervals)
		{
			hash = MurmurHash.update(hash, I.a);
			hash = MurmurHash.update(hash, I.b);
		}

		hash = MurmurHash.finish(hash, intervals.size * 2);
		return hash;
	}

	/**
	 * Are two IntervalSets equal?  Because all intervals are sorted
     * and disjoint, equals is a simple linear walk over both lists
     * to make sure they are the same.  Interval.equals() is used
     * by the List.equals() method to check the ranges.
     */
    public bool equals(IntSet _is)
	{
        if (_is == null || !(_is is IntSet))
            return false;

        if (_is is IntervalSet)
        {
            var other = _is as IntervalSet;
            for (var i = 0; i < intervals.size; i++)
		        if (!intervals[i].equals(other.intervals[i]))
		            return false;
        }
        else return this == _is;
	}

	public string to_string(bool elem_are_char = false)
	{
		StringBuilder buf = new StringBuilder();
		if (this.intervals == null || this.intervals.is_empty())
			return "{}";

		if (this.size() > 1)
			buf.append("{");

		var iter = this.intervals.iterator();
		while (iter.has_next())
		{
			Interval I = iter.get();
			iter.next();
			int a = I.a;
			int b = I.b;
			if (a == b)
		    {
				if (a == Token.EOF) buf.append("<EOF>");
				else if (elem_are_char) buf.append("'")
				                           .append_unichar(a as unichar)
				                           .append("'");
				else buf.append(a);
			}
			else
			{
				if (elem_are_char ) buf.append("'")
				                       .append_unichar(a as unichar)
				                       .append("'..'")
				                       .append_unichar(b as unichar)
				                       .append("'");
				else buf.append_unichar(a as unichar)
				        .append("..")
				        .append_unichar(b as unichar);
			}
			if (iter.has_next())
				buf.append(", ");
		}
		if (this.size() > 1)
			buf.append("}");

		return buf.str;
	}

	/**
	 * @deprecated Use {@link #tostring(Vocabulary)} instead.
	 */
	[Deprecated]
	public string tostring0(string[] token_names)
	{
		return to_string_vocab(VocabularyImpl.from_token_names(token_names));
	}

	public string to_string_vocab(Vocabulary vocabulary)
	{
		StringBuilder buf = new StringBuilder();
		if (this.intervals == null || this.intervals.is_empty)
			return "{}";

		if (this.size() > 1)
			buf.append("{");

		var iter = this.intervals.iterator();
		while (iter.has_next())
		{
			Interval I = iter.get();
			iter.next();
			int a = I.a;
			int b = I.b;
			if (a == b)
				buf.append(element_name(vocabulary, a));

			else {
				for (int i=a; i<=b; i++)
		{
					if (i>a ) buf.append(", ");
                    buf.append(element_name(vocabulary, i));
				}
			}
			if (iter.hasNext() )
		{
				buf.append(", ");
			}
		}
		if (this.size()>1 )
		{
			buf.append("}");
		}
        return buf.tostring();
    }

	/**
	 * @deprecated Use {@link #element_name(Vocabulary, int)} instead.
	 */
	[Version (deprecated = true, deprecated_since = "4.7", replacement = "element_name(Antlr4.Runtime.Vocabulary, int)")]
	protected string _element_name(string[] token_names, int a)
	{
		return element_name(VocabularyImpl.from_token_names(token_names), a);
	}


	protected string element_name(Vocabulary vocabulary, int a)
	{
		if (a == Token.EOF)
			return "<EOF>";

		else if (a == Token.EPSILON)
			return "<EPSILON>";

		else return vocabulary.get_display_name(a);
	}

    public int size {
	    get
	    {
		    int n = 0;
		    int num_intervals = intervals.size;
		    if (num_intervals == 1)
		    {
			    Interval first_interval = this.intervals.get(0);
			    return first_interval.b - first_interval.a + 1;
		    }
		    for (int i = 0; i < num_intervals; i++)
		    {
			    Interval I = intervals.get(i);
			    n += (I.b - I.a + 1);
		    }
		    return n;
		}
    }

	public IntegerList to_integer_list() throws OptionError, OutOfMemoryError
	{
		IntegerList values = new IntegerList(size);
		int n = intervals.size;
		for (int i = 0; i < n; i++)
		{
			Interval I = intervals.get(i);
			int a = I.a;
			int b = I.b;
			for (int v=a; v<=b; v++)
				values.add(v);
		}
		return values;
	}

    public Gee.List<int> to_list()
	{
		var values = new Gee.ArrayList<int>();
		int n = intervals.size;
		for (int i = 0; i < n; i++)
		{
			Interval I = intervals.get(i);
			int a = I.a;
			int b = I.b;
			for (int v=a; v<=b; v++)
				values.add(v);
		}
		return values;
	}

	public Gee.Set<int> to_set()
	{
		var s = new Gee.HashSet<int>();
		foreach (Interval I in intervals)
		{
			int a = I.a;
			int b = I.b;
			for (int v = a; v <= b; v++)
				s.add(v);
		}
		return s;
	}

	/**
	 * Get the ith element of ordered set. Used only by RandomPhrase so
	 * don't bother to implement if you're not doing that for a new
	 * ANTLR code gen target.
	 */
	public new int get(int i)
	{
		int n = intervals.size;
		int index = 0;
		for (int j = 0; j < n; j++)
		{
			Interval I = intervals.get(j);
			int a = I.a;
			int b = I.b;
			for (int v=a; v<=b; v++)
				if (index == i)
					return v;

				index++;
		}
		return -1;
	}

	public int[] to_array() throws OptionError, OutOfMemoryError
	{
		return to_integer_list().to_array();
	}

	public void remove(int el) throws StateError
	{
        verify_alter();
        int n = intervals.size;
        for (int i = 0; i < n; i++)
		{
            Interval I = intervals.get(i);
            int a = I.a;
            int b = I.b;
            if (el < a)
                break; // list is sorted and el is before this interval; not here

            // if whole interval x..x, rm
            if (el == a && el == b)
		    {
                intervals.remove_at(i);
                break;
            }
            // if on left edge x..b, adjust left
            if (el == a)
		    {
                I.a++;
                break;
            }
            // if on right edge a..x, adjust right
            if (el == b)
		    {
                I.b--;
                break;
            }
            // if in middle a..x..b, split interval
            if (el > a && el < b)
		    { // found in this interval
                int oldb = I.b;
                I.b = el-1;      // [a..x-1]
                add_range(el + 1, oldb); // add [x+1..b]
            }
        }
    }
}
