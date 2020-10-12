/* integerlist.vala
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

public class Antlr4.Runtime.Misc.IntegerList : GLib.Object, Hashable
{
	private static int[] EMPTY_DATA = new int[0];

	private const int INITIAL_SIZE = 4;
	private const int MAX_ARRAY_SIZE = int.MAX - 8;


	private int[] _data;

	private int _size;

	public IntegerList(int capacity = 0) throws OptionError
	{
		if (capacity < 0)
			throw new OptionError.BAD_VALUE ("capacity < 0");

		if (capacity == 0)
			_data = EMPTY_DATA;

		else
		{
			_data = new int[capacity];
		}
	}

	public IntegerList.dup(IntegerList list)
	{
	    _data = list._data.copy();
		_size = list._size;
	}

	public IntegerList.collection(Gee.Collection<int> list) throws OptionError, OutOfMemoryError
	{
		this(list.size);
		foreach (var value in list)
			add(value);
	}

	public sealed void add(int value) throws OutOfMemoryError
	{
		if (_data.length == _size)
			ensure_capacity(_size + 1);

		_data[_size] = value;
		_size++;
	}

	public sealed void add_all(int[] array) throws OutOfMemoryError
	{
		ensure_capacity(_size + array.length);
		Util.array_copy<int>(array, 0, ref _data, _size, array.length);
		_size += array.length;
	}

	public sealed void add_all_ilist(IntegerList list) throws OutOfMemoryError
	{
		ensure_capacity(_size + list._size);
		Util.array_copy<int>(list._data, 0, ref _data, _size, list._size);
		_size += list._size;
	}

	public sealed void add_all_collection(Gee.Collection<int> list) throws OutOfMemoryError
	{
		ensure_capacity(_size + list.size);
		int current = 0;
    	foreach (int x in list)
	    {
      	    _data[_size + current] = x;
      		current++;
    	}
    	_size += list.size;
	}

	public new sealed int get(int index) throws IndexError
	{
		if (index < 0 || index >= _size)
			throw new IndexError.OUT_OF_RANGE ("index < 0 || index >= _size");

		return _data[index];
	}

	public sealed bool contains(int value)
	{
		for (int i = 0; i < _size; i++)
			if (_data[i] == value)
				return true;

		return false;
	}

	public new sealed int set(int index, int value) throws IndexError
	{
		if (index < 0 || index >= _size)
	    {
			throw new IndexError.OUT_OF_RANGE ("index < 0 || index >= _size");
		}

		int previous = _data[index];
		_data[index] = value;
		return previous;
	}

	public sealed int remove_at(int index) throws IndexError
	{
		int value = get(index);
		Util.array_copy<int>(_data, index + 1, ref _data, index, _size - index - 1);
		_data[_size - 1] = 0;
		_size--;
		return value;
	}

	public sealed void remove_range(int from_index, int to_index) throws OptionError, IndexError
	{
		if (from_index < 0 || to_index < 0 || from_index > _size || to_index > _size)
			throw new IndexError.OUT_OF_RANGE ("from_index < 0 || to_index < 0 || from_index > _size || to_index > _size");
		if (from_index > to_index)
			throw new OptionError.BAD_VALUE ("from_index > to_index");

		Util.array_copy<int>(_data, to_index, ref _data, from_index, _size - to_index);
		Util.array_fill(ref _data, _size - (to_index - from_index), _size, 0);
		_size -= (to_index - from_index);
	}

	public sealed bool is_empty()
	{
		return _size == 0;
	}

	public sealed int size { get { return _size; } }

	public sealed void trim_to_size()
	{
		if (_data.length == _size)
			return;

		_data = Util.array_copy_of(_data, _size);

	}

	public sealed void clear() throws OptionError, IndexError
	{
		Util.array_fill(ref _data, 0, _size, 0);
		_size = 0;
	}

	public sealed int[] to_array()
	{
		if (_size == 0)
			return EMPTY_DATA;

		return Util.array_copy_of(_data, _size);
	}

	public sealed void sort()
	{
	    var sorted = new Array<int>();
	    foreach (var e in _data) sorted.append_val(e);
	    sorted.sort((a, b) =>
	    {
	        return (a > b) ? a : b;
	    });
	}

	public bool equals(IntegerList l)
	{
		if (l == this)
			return true;

		if (_size != l._size)
			return false;

		for (int i = 0; i < _size; i++)
			if (_data[i] != l._data[i])
				return false;

		return true;
	}

	public override uint64 hash_code()
	{
		int hash = 1;
		for (int i = 0; i < _size; i++)
			hash = 31 * hash + _data[i];

		return hash;
	}

	/**
	 * Returns a string representation of this list.
	 */
	public string to_string()
	{
		var builder = new StringBuilder();
		builder.append("{");
		var i = 0;
		for (; i < (_size - 1); i++)
		    builder.append(_data[i].to_string()).append(", ");

		builder.append(_data[i].to_string()).append("}");
		return builder.str;

	}

	public sealed uint binary_search(int key, int from_index = 0, int to_index = size) throws OptionError, IndexError
	{
		if (from_index < 0 || to_index < 0 || from_index > _size || to_index > _size)
			throw new IndexError.OUT_OF_RANGE("from_index < 0 || to_index < 0 || from_index > _size || to_index > _size");
		if (from_index > to_index)
        		throw new OptionError.BAD_VALUE("from_index > to_index");

		return Util.binary_search(_data, from_index, to_index, key);
	}

	private void ensure_capacity(int capacity) throws OutOfMemoryError
	{
		if (capacity < 0 || capacity > MAX_ARRAY_SIZE)
			throw new OutOfMemoryError.OUT_OF_MEMORY("capacity < 0 || capacity > MAX_ARRAY_SIZE");

		int new_length;
		if (_data.length == 0)
			new_length = INITIAL_SIZE;
		else new_length = _data.length;

		while (new_length < capacity)
	    {
			new_length = new_length * 2;
			if (new_length < 0 || new_length > MAX_ARRAY_SIZE)
				new_length = MAX_ARRAY_SIZE;
		}

		_data = Util.array_copy_of(_data, new_length);
	}

	/**
	 * Convert the list to a UTF-16 encoded char array. If all values are less
	 * than the 0xFFFF 16-bit code point limit then this is just a char array
	 * of 16-bit char as usual. For values in the supplementary range, encode
	 * them as two UTF-16 code units.
	 */
	public sealed char[] to_char_array() throws OptionError
	{
		// Optimize for the common case (all data values are
		// < 0xFFFF) to avoid an extra scan
		char[] result_array = new char[_size];
		int result_idx = 0;
		bool calculated_precise_result_size = false;
		int code_point;
		int chars_written;
		for (int i = 0; i < _size; i++)
	    {
			code_point = _data[i];
			// Calculate the precise result size if we encounter
			// a code point > 0xFFFF
			if (!calculated_precise_result_size &&
			    Util.is_supplementary_code_point(code_point))
	        {
				result_array = Util.array_copy_of(result_array, char_array_size());
				calculated_precise_result_size = true;
			}
			// This will throw IllegalArgumentException if
			// the code point is not a valid Unicode code point
			chars_written = Util.to_chars(code_point, ref result_array, result_idx);
			result_idx += chars_written;
		}
		return result_array;
	}

	private int char_array_size()
	{
		int result = 0;
		for (int i = 0; i < _size; i++)
			result += Util.char_count(_data[i]);
		return result;
	}
}
