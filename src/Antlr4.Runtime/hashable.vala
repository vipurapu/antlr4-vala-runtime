/* hashable.vala
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
 * Because {@link GLib.Object} doesn't have
 * any kind of hash implementation, I made
 * this interface for things that may be hashed
 * by {@link Antlr4.Runtime.Misc.EqualityComparator}.
 */
public interface Antlr4.Runtime.Hashable : GLib.Object
{
    /**
     * Returns the hash code for this.
     */
    public abstract uint64 hash_code();
}
