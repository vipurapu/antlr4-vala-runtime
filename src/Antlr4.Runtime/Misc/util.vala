/* util.vala
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
using Antlr4.Runtime.Dfa;
using Antlr4.Runtime.Error;

public class Antlr4.Runtime.Misc.Util
{
    private const uint MIN_SUPPLEMENTARY_CODE_POINT = 0x010000;
    private const uint MAX_CODE_POINT = 0x10FFFF;
    private const char MIN_LOW_SURROGATE = 0xDC00;
    private const char MIN_HIGH_SURROGATE = 0xD800;

    public static bool array_equals<E>(E[]? a, E[]? a2)
    {
        if (a == a2)
            return true;
        if (a == null || a2 == null)
            return false;

        int length = a.length;
        if (a2.length != length)
            return false;

        for (var i = 0; i < length; i++)
            if (a[i] != a2[i])
                return false;

        return true;
    }

    internal static void array_copy<G>(G[] src, uint src_pos, out G[] dest, uint dest_pos, uint length)
    {
        for (var i = 0; i < length; i++)
            dest[i + dest_pos] = src[i + src_pos];
    }

    internal static void array_fill<G>(out G[] a, uint from_index, uint to_index, G val) throws OptionError, IndexError
    {
        range_check(a.length, from_index, to_index);
        for (var i = from_index; i < to_index; i++)
            a[i] = val;
    }

    private static void range_check(uint array_length, uint from_index, uint to_index) throws OptionError, IndexError
    {
        if (from_index > to_index)
            throw new OptionError.BAD_VALUE(
                    "from_index(" + from_index.to_string() + ") > to_index(" + to_index.to_string() + ")");
        if (from_index < 0)
            throw new IndexError.OUT_OF_RANGE("from_index < 0");
        if (to_index > array_length)
            throw new IndexError.OUT_OF_RANGE("to_index > array_length");
    }

    public static G[] array_copy_of<G>(G[] original, uint new_length)
    {
        var copy = new G[new_length];
        array_copy(original, 0, out copy, 0,
                         min(original.length, new_length));
        return copy;
    }

    public static uint min(uint a, uint b)
    {
        return (a <= b) ? a : b;
    }

    public static uint max(uint a, uint b)
    {
        return (a <= b) ? b : a;
    }

    public static uint binary_search(int[] a, uint from_index, uint to_index, uint key) throws OptionError, IndexError
    {
        range_check(a.length, from_index, to_index);
        uint low = from_index;
        uint high = to_index - 1;

        while (low <= high) {
            uint mid = (low + high) >> 1;
            uint mid_val = a[mid];

            if (mid_val < key)
                low = mid + 1;
            else if (mid_val > key)
                high = mid - 1;
            else
                return mid;
        }

        return -(low + 1);
    }

    public static bool is_supplementary_code_point(int code_point)
    {
        return code_point >= MIN_SUPPLEMENTARY_CODE_POINT
            && code_point <  MAX_CODE_POINT + 1;
    }

    public static uint to_chars(int code_point, out char[] dst, uint dst_index) throws OptionError
    {
        if (is_bmp_code_point(code_point)) {
            dst[dst_index] = (char) code_point;
            return 1;
        } else if (is_valid_code_point(code_point)) {
            to_surrogates(code_point, dst, dst_index);
            return 2;
        } else throw new OptionError.BAD_VALUE("code_point");
    }

    static void to_surrogates(int code_point, char[] dst, uint index)
    {
        dst[index + 1] = low_surrogate(code_point);
        dst[index] = high_surrogate(code_point);
    }

    public static char low_surrogate(int codePoint)
    {
        return (char) ((codePoint & 0x3ff) + MIN_LOW_SURROGATE);
    }

    public static char high_surrogate(int code_point)
    {
        return (char) ((code_point >> 10)
            + (MIN_HIGH_SURROGATE - (MIN_SUPPLEMENTARY_CODE_POINT >> 10)));
    }

    public static bool is_valid_code_point(int code_point)
    {
        uint plane = code_point >> 16;
        return plane < ((MAX_CODE_POINT + 1) >> 16);
    }

    public static bool is_bmp_code_point(int code_point)
    {
        return code_point >> 16 == 0;
    }

    public static uint char_count(int code_point)
    {
        return code_point >= MIN_SUPPLEMENTARY_CODE_POINT ? 2 : 1;
    }

    public static uint number_of_trailing_zeros(ulong i)
    {
        uint x, y;
        if (i == 0) return 64;
        uint n = 63;
        y = (uint) i;
        if (y != 0) { n = n -32; x = y; }
        else x = (uint) (i >> 32);
        y = x << 16; if (y != 0) { n = n -16; x = y; }
        y = x <<  8; if (y != 0) { n = n - 8; x = y; }
        y = x <<  4; if (y != 0) { n = n - 4; x = y; }
        y = x <<  2; if (y != 0) { n = n - 2; x = y; }
        return n - ((x << 1) >> 31);
    }

    public static uint number_of_leading_zeros(ulong i)
    {
        if (i == 0) return 64;
        uint n = 1;
        uint x = (uint) (i >> 32);
        if (x == 0) { n += 32; x = (uint) i; }
        if (x >> 16 == 0) { n += 16; x <<= 16; }
        if (x >> 24 == 0) { n +=  8; x <<=  8; }
        if (x >> 28 == 0) { n +=  4; x <<=  4; }
        if (x >> 30 == 0) { n +=  2; x <<=  2; }
        n -= x >> 31;
        return n;
    }

    public static uint bit_count(ulong i)
    {
        i = i - ((i >> 1) & 0x5555555555555555L);
        i = (i & 0x3333333333333333L) + ((i >> 2) & 0x3333333333333333L);
        i = (i + (i >> 4)) & 0x0f0f0f0f0f0f0f0fL;
        i = i + (i >> 8);
        i = i + (i >> 16);
        i = i + (i >> 32);
        return (uint) i & 0x7f;
    }

    public static Gee.Map<string, int> to_map(string[] keys)
    {
		var m = new Gee.HashMap<string, int>();
		for (int i = 0; i < keys.length; i++)
			m[keys[i]] = i;

		return m;
	}

	public static string join_string(string start, string end, string delim, string[] s) requires (s.length > 0)
	{
	    if (s.length != 1)
	    {
	        var builder = new StringBuilder();
	        builder.append(start);
	        var i = 0;

	            for ( ; i < s.length - 1; i++)
	                builder.append(s[i]).append(delim);

	        return builder.str + s[i] + end;
	    }
	    else return start + s[0] + end;
	}
} 
