/* murmurhash.vala
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

public class Antlr4.Runtime.Misc.MurmurHash
{
    /**
     * The default seed for the hash algorithm.
     */
    public const int64 DEFAULT_SEED = 0;

    /**
	 * Initialize the hash using the default seed value,
	 * or if specified, the given value.
	 *
	 * @return the intermediate hash value
	 */
    public static int64 initialize(int64 seed = DEFAULT_SEED)
    {
        return seed;
    }

    /**
	 * Update the intermediate hash value for the next input value.
	 *
	 * @param _hash the intermediate hash value
	 * @param val the value to add to the current hash
	 * @return the updated intermediate hash value
	 */
    public static int64 update(int64 _hash, int64 val)
    {
        var hash = (uint64) _hash;
		uint64 c1 = 0xCC9E2D51;
		uint64 c2 = 0x1B873593;
		uint64 r1 = 15;
		uint64 r2 = 13;
		uint64 m = 5;
		uint64 n = 0xE6546B64;

		uint64 k = val;
		k = k * c1;
		k = (k << r1) | (k >> (32 - r1));
		k = k * c2;

		hash = hash ^ k;
		hash = (hash << r2) | (hash >> (32 - r2));
		hash = hash * m + n;

		return (int64) hash;
	}

    /**
	 * Update the intermediate hash value for the next input value.
	 *
	 * @param hash the intermediate hash value
	 * @param val the value to add to the current hash
	 * @return the updated intermediate hash value
	 */
	public static int64 _update(int64 hash, Hashable val) requires(val != null)
	{
	    return update(hash, ((int64) ((Hashable) val).hash_code()));
	}

    /**
	 * Apply the final computation steps to the intermediate value hash
	 * to form the final result of the MurmurHash 3 hash function.
	 *
	 * @param hash the intermediate hash value
	 * @param numberOfWords the number of integer values added to the hash
	 * @return the final hash result
	 */
	public static int64 finish(uint64 hash, int numberOfWords)
	{
		hash = hash ^ (numberOfWords * 4);
		hash = hash ^ (hash >> 16);
		hash = hash * 0x85EBCA6B;
		hash = hash ^ (hash >> 13);
		hash = hash * 0xC2B2AE35;
		hash = hash ^ (hash >> 16);
		return (int64) hash;
	}

	/**
	 * Utility function to compute the hash code of an array using the
	 * MurmurHash algorithm.
	 *
	 * @param data the array data
	 * @param seed the seed for the MurmurHash algorithm
	 * @return the hash code of the data
	 */
	public static int64 hash_code(Hashable[] data, int seed)
	{
		int64 hash = initialize(seed);
		foreach (var val in data)
			hash = _update(hash, val);

		hash = finish(hash, data.length);
		return hash;
	}

	private MurmurHash() { }
}
