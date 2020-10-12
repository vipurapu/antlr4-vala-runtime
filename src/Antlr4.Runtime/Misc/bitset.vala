/* bitset.vala
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

public class Antlr4.Runtime.Misc.BitSet : GLib.Object, Hashable
{
    private const int ADDRESS_BITS_PER_WORD = 6;
    private const int BITS_PER_WORD = 64;
    private const int BIT_INDEX_MASK = 63;
    private const ulong WORD_MASK = -1L;
    private ulong[] words;
    private unowned uint words_in_use = 0;
    private unowned bool size_is_sticky = false;

    private static uint word_index(uint bit_index)
    {
        return bit_index >> 6;
    }

    private void check_invariants()
    {
        assert(this.words_in_use == 0 || this.words[this.words_in_use - 1] != 0L);
        assert(this.words_in_use >= 0 && this.words_in_use <= this.words.length);
        assert(this.words_in_use == this.words.length || this.words[this.words_in_use] == 0L);
    }

    private void recalculate_words_in_use()
    {
        uint i;
        for (i = this.words_in_use - 1; i >= 0 && this.words[i] == 0L; --i) { }
        this.words_in_use = i + 1;
    }

    public BitSet(uint nbits = 64) throws IndexError
    {
        this.init_words(nbits);
        this.size_is_sticky = true;
    }

    private void init_words(uint nbits)
    {
        this.words = new ulong[word_index(nbits - 1) + 1];
    }

    private BitSet.long(ulong[] words)
    {
        this.words = words;
        this.words_in_use = words.length;
        this.check_invariants();
    }

    public static BitSet value_of(ulong[] longs)
    {
        int n;
        for(n = longs.length; n > 0 && longs[n - 1] == 0L; --n) { }

        return new BitSet.long(Util.array_copy_of<ulong>(longs, n));
    }

    public ulong[] to_long_array()
    {
        return Util.array_copy_of<ulong>(this.words, this.words_in_use);
    }

    private void ensure_capacity(uint words_required)
    {
        if (this.words.length < words_required)
        {
            uint request = Util.max(2 * this.words.length, words_required);
            this.words = Util.array_copy_of(this.words, request);
            this.size_is_sticky = false;
        }

    }

    private void expand_to(uint word_index)
    {
        uint words_required = word_index + 1;
        if (this.words_in_use < words_required)
        {
            this.ensure_capacity(words_required);
            this.words_in_use = words_required;
        }

    }

    private static void check_range(uint from_index, uint to_index) throws IndexError
    {
        if (from_index < 0)
            throw new IndexError.OUT_OF_RANGE("from_index < 0: " + from_index.to_string());
        else if (to_index < 0)
            throw new IndexError.OUT_OF_RANGE("to_index < 0: " + to_index.to_string());
        else if (from_index > to_index)
            throw new IndexError.OUT_OF_RANGE("from_index: " + from_index.to_string() + " > to_index: " + to_index.to_string());
    }

    public void flip(int bit_index) throws IndexError
    {
        if (bit_index < 0)
            throw new IndexError.OUT_OF_RANGE("bit_index < 0: " + bit_index.to_string().to_string());
        else
        {
            uint word_index = word_index(bit_index);
            this.expand_to(word_index);
            ulong[] old_words = this.words;
            old_words[word_index] ^= 1L << bit_index;
            this.recalculate_words_in_use();
            this.check_invariants();
        }
    }

    public void flip_range(int from_index, int to_index) throws IndexError
    {
        check_range(from_index, to_index);
        if (from_index != to_index)
        {
            uint startword_index = word_index(from_index);
            uint endword_index = word_index(to_index - 1);
            this.expand_to(endword_index);
            ulong first_word_mask = -1L << from_index;
            ulong last_word_mask = -1L >> -to_index;
            ulong[] result;
            if (startword_index == endword_index)
            {
                result = this.words;
                result[startword_index] ^= first_word_mask & last_word_mask;
            } else
            {
                result = this.words;
                result[startword_index] ^= first_word_mask;

                for(uint i = startword_index + 1; i < endword_index; ++i)
                {
                    result = this.words;
                    result[i] = ~result[i];
                }

                result = this.words;
                result[endword_index] ^= last_word_mask;
            }

            this.recalculate_words_in_use();
            this.check_invariants();
        }
    }

    public new void set(int bit_index, bool value = false) throws IndexError
    {
        if (value)
        {
            if (bit_index < 0)
                throw new IndexError.OUT_OF_RANGE("bit_index < 0: " + bit_index.to_string());
            else
            {
                uint word_index = word_index(bit_index);
                this.expand_to(word_index);
                ulong[] result = this.words;
                result[word_index] |= 1L << bit_index;
                this.check_invariants();
            }
        } else this.clear(bit_index);
    }

    private void set_range0(int from_index, int to_index) throws IndexError
    {
        check_range(from_index, to_index);
        if (from_index != to_index)
        {
            uint startword_index = word_index(from_index);
            uint endword_index = word_index(to_index - 1);
            this.expand_to(endword_index);
            ulong first_word_mask = -1L << from_index;
            ulong last_word_mask = -1L >> -to_index;
            ulong[] result;
            if (startword_index == endword_index)
            {
                result = this.words;
                result[startword_index] |= first_word_mask & last_word_mask;
            }
            else
            {
                result = this.words;
                result[startword_index] |= first_word_mask;

                for(uint i = startword_index + 1; i < endword_index; ++i) {
                    this.words[i] = -1L;
                }

                result = this.words;
                result[endword_index] |= last_word_mask;
            }

            this.check_invariants();
        }
    }

    public void set_range(int from_index, int to_index, bool value = false) throws IndexError
    {
        if (value) this.set_range0(from_index, to_index);
        else this.clear_range(from_index, to_index);
    }

    public void clear(int bit_index) throws IndexError
    {
        if (bit_index < 0)
            throw new IndexError.OUT_OF_RANGE("bit_index < 0: " + bit_index.to_string().to_string());
        else
        {
            uint word_index = word_index(bit_index);
            if (word_index < this.words_in_use) {
                ulong[] result = this.words;
                result[word_index] &= ~(1L << bit_index);
                this.recalculate_words_in_use();
                this.check_invariants();
            }
        }
    }

    public void clear_range(uint from_index, uint to_index) throws IndexError
    {
        check_range(from_index, to_index);
        if (from_index != to_index)
        {
            uint startword_index = word_index(from_index);
            if (startword_index < this.words_in_use) {
                uint endword_index = word_index(to_index - 1);
                if (endword_index >= this.words_in_use) {
                    to_index = this.length();
                    endword_index = this.words_in_use - 1;
                }

                ulong first_word_mask = -1L << from_index;
                ulong last_word_mask = -1L >> -to_index;
                ulong[] result;
                if (startword_index == endword_index) {
                    result = this.words;
                    result[startword_index] &= ~(first_word_mask & last_word_mask);
                } else {
                    result = this.words;
                    result[startword_index] &= ~first_word_mask;

                    for(uint i = startword_index + 1; i < endword_index; ++i) {
                        this.words[i] = 0L;
                    }

                    result = this.words;
                    result[endword_index] &= ~last_word_mask;
                }

                this.recalculate_words_in_use();
                this.check_invariants();
            }
        }
    }

    public void clear_all()
    {
        while(this.words_in_use > 0)
            this.words[--this.words_in_use] = 0L;
    }

    public new bool get(int bit_index) throws IndexError
    {
        if (bit_index < 0)
            throw new IndexError.OUT_OF_RANGE("bit_index < 0: " + bit_index.to_string());
        else
        {
            this.check_invariants();
            uint word_index = word_index(bit_index);
            return word_index < this.words_in_use && (this.words[word_index] & 1L << bit_index) != 0L;
        }
    }

    public BitSet subset(uint from_index, uint to_index) throws IndexError
    {
        check_range(from_index, to_index);
        this.check_invariants();
        uint len = this.length();
        if (len > from_index && from_index != to_index)
        {
            if (to_index > len)
                to_index = len;


            BitSet result = new BitSet(to_index - from_index);
            uint target_words = word_index(to_index - from_index - 1) + 1;
            uint source_index = word_index(from_index);
            bool word_aligned = (from_index & 63) == 0;

            for(int i = 0; i < target_words - 1; ++source_index)
            {
                result.words[i] = word_aligned ? this.words[source_index] : this.words[source_index] >> from_index | this.words[source_index + 1] << -from_index;
                ++i;
            }

            ulong last_word_mask = -1L >> -to_index;
            result.words[target_words - 1] = (to_index - 1 & 63) < (from_index & 63)
                            ? this.words[source_index] >> from_index |
                            (this.words[source_index + 1] & last_word_mask)
                            << -from_index : (this.words[source_index] &
                            last_word_mask) >> from_index;
            result.words_in_use = target_words;
            result.recalculate_words_in_use();
            result.check_invariants();
            return result;
        } else return new BitSet(0);
    }

    public uint next_set_bit(uint from_index) throws IndexError
    {
        if (from_index < 0)
            throw new IndexError.OUT_OF_RANGE("from_index < 0: " + from_index.to_string());
        else
        {
            this.check_invariants();
            uint u = word_index(from_index);
            if (u >= this.words_in_use)
                return -1;
            else
            {
                ulong word;
                for (word = this.words[u] & -1L << from_index; word == 0L; word = this.words[u])
                {
                    ++u;
                    if (u == this.words_in_use)
                        return -1;
                }
                return u * 64 + Util.number_of_trailing_zeros(word);
            }
        }
    }

    public uint next_clear_bit(uint from_index) throws IndexError
    {
        if (from_index < 0)
            throw new IndexError.OUT_OF_RANGE("from_index < 0: " + from_index.to_string());
        else
        {
            this.check_invariants();
            uint u = word_index(from_index);
            if (u >= this.words_in_use)
                return from_index;
            else {
                ulong word;
                for (word = ~this.words[u] & -1L << from_index; word == 0L; word = ~this.words[u]) {
                    ++u;
                    if (u == this.words_in_use)
                        return this.words_in_use * 64;
                }

                return u * 64 + Util.number_of_trailing_zeros(word);
            }
        }
    }

    public uint previous_set_bit(int from_index) throws IndexError
    {
        if (from_index < 0) {
            if (from_index == -1)
                return -1;
            else throw new IndexError.OUT_OF_RANGE("from_index < -1: " + from_index.to_string());
        }
        else
        {
            this.check_invariants();
            uint u = word_index(from_index);
            if (u >= this.words_in_use)
                return this.length() - 1;
            else
            {
                ulong word;
                for (word = this.words[u] & -1L >> -(from_index + 1); word == 0L; word = this.words[u]) {
                    if (u-- == 0) {
                        return -1;
                    }
                }

                return (u + 1) * 64 - 1 - Util.number_of_leading_zeros(word);
            }
        }
    }

    public uint previous_clear_bit(int from_index) throws IndexError
    {
        if (from_index < 0)
        {
            if (from_index == -1)
                return -1;
            else throw new IndexError.OUT_OF_RANGE("from_index < -1: " + from_index.to_string());
        }
        else
        {
            this.check_invariants();
            uint u = word_index(from_index);
            if (u >= this.words_in_use)
                return from_index;
            else
            {
                ulong word;
                for (word = ~this.words[u] & -1L >> -(from_index + 1); word == 0L; word = ~this.words[u]) {
                    if (u-- == 0)
                        return -1;
                }

                return (u + 1) * 64 - 1 - Util.number_of_leading_zeros(word);
            }
        }
    }

    public uint length()
    {
        return this.words_in_use == 0 ? 0 : 64 * (this.words_in_use - 1) + (64 - Util.number_of_leading_zeros(this.words[this.words_in_use - 1]));
    }

    public bool is_empty()
    {
        return this.words_in_use == 0;
    }

    public bool intersects(BitSet set)
    {
        for (uint i = Util.min(this.words_in_use, set.words_in_use) - 1; i >= 0; --i)
        {
            if ((this.words[i] & set.words[i]) != 0L)
                return true;
        }

        return false;
    }

    public uint cardinality()
    {
        uint sum = 0;

        for(int i = 0; i < this.words_in_use; ++i)
            sum += Util.bit_count(this.words[i]);

        return sum;
    }

    public void and(BitSet set)
    {
        if (this != set)
        {
            while(this.words_in_use > set.words_in_use)
                this.words[--this.words_in_use] = 0L;

            for(int i = 0; i < this.words_in_use; ++i)
            {
                ulong[] result = this.words;
                result[i] &= set.words[i];
            }

            this.recalculate_words_in_use();
            this.check_invariants();
        }
    }

    public void or(BitSet set)
    {
        if (this != set)
        {
            uint words_in_common = Util.min(this.words_in_use, set.words_in_use);
            if (this.words_in_use < set.words_in_use)
            {
                this.ensure_capacity(set.words_in_use);
                this.words_in_use = set.words_in_use;
            }

            for(int i = 0; i < words_in_common; ++i)
{
                ulong[] result = this.words;
                result[i] |= set.words[i];
            }

            if (words_in_common < set.words_in_use)
                Util.array_copy<ulong>(set.words, words_in_common, out this.words, words_in_common, this.words_in_use - words_in_common);

            this.check_invariants();
        }
    }

    public void xor(BitSet set)
    {
        uint words_in_common = Util.min(this.words_in_use, set.words_in_use);
        if (this.words_in_use < set.words_in_use)
        {
            this.ensure_capacity(set.words_in_use);
            this.words_in_use = set.words_in_use;
        }

        for(int i = 0; i < words_in_common; ++i)
        {
            ulong[] result = this.words;
            result[i] ^= set.words[i];
        }

        if (words_in_common < set.words_in_use)
            Util.array_copy<ulong>(set.words, words_in_common, out this.words, words_in_common, set.words_in_use - words_in_common);

        this.recalculate_words_in_use();
        this.check_invariants();
    }

    public void and_not(BitSet set)
    {
        for (uint i = Util.min(this.words_in_use, set.words_in_use) - 1; i >= 0; --i)
        {
            ulong[] result = this.words;
            result[i] &= ~set.words[i];
        }

        this.recalculate_words_in_use();
        this.check_invariants();
    }

    public uint64 hash_code()
    {
        ulong h = 1234L;
        uint i = this.words_in_use;

        while(true)
        {
            --i;
            if (i < 0)
                return (h >> 32 ^ h);

            h ^= this.words[i] * (i + 1);
        }
    }

    public int size()
    {
        return this.words.length * 64;
    }

    public bool equals(BitSet _set)
    {
        if (ObjectEqualityComparator.INSTANCE.equals(this, _set))
            return true;
        else
        {
            this.check_invariants();
            _set.check_invariants();
            if (this.words_in_use != _set.words_in_use)
                return false;
            else
            {
                for(int i = 0; i < this.words_in_use; ++i)
                {
                    if (this.words[i] != _set.words[i])
                        return false;
                }

                return true;
            }
        }
    }

    private void trim_to_size()
    {
        if (this.words_in_use != this.words.length)
        {
            this.words = Util.array_copy_of<ulong>(this.words, this.words_in_use);
            this.check_invariants();
        }

    }

    public string to_string() throws IndexError
    {
        this.check_invariants();
        uint num_bits = this.words_in_use > 128 ? this.cardinality() : this.words_in_use * 64;
        StringBuilder b = new StringBuilder.sized(6 * num_bits + 2);
        b.append_c('{');
        uint i = this.next_set_bit(0);
        if (i != -1)
        {
            b.append(i.to_string());

            while(true)
            {
                ++i;
                if (i < 0 || (i = this.next_set_bit(i)) < 0)
                {
                    break;
                }

                uint end_of_run = this.next_clear_bit(i);

                while(true) {
                    b.append(", ").append(i.to_string());
                    ++i;
                    if (i == end_of_run) {
                        break;
                    }
                }
            }
        }

        b.append_c('}');
        return b.str;
    }

    private uint _next_set_bit(int from_index, int toword_index)
    {
        uint u = word_index(from_index);
        if (u > toword_index)
            return -1;
        else
        {
            ulong word;
            for(word = this.words[u] & -1L << from_index; word == 0L; word = this.words[u])
            {
                ++u;
                if (u > toword_index)
                    return -1;
            }

            return u * 64 + Util.number_of_trailing_zeros(word);
        }
    }
}

