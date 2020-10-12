/* tree.vala
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
 * The basic notion of a tree has a parent, a payload, and a list of children.
 * It is the most abstract interface for all the trees used by ANTLR.
 */
public interface Antlr4.Runtime.Tree.BaseTree : GLib.Object
{
	/**
	 * The parent of this node. If the return value is null, then this
	 * node is the root of the tree.
	 */
	public abstract BaseTree parent { get; set; }

	/**
	 * This method returns whatever object represents the data at this note. For
	 * example, for parse trees, the payload can be a {@link Token} representing
	 * a leaf node or a {@link RuleContext} object representing a rule
	 * invocation. For abstract syntax trees (ASTs), this is a {@link Token}
	 * object.
	 */
	public abstract GLib.Object payload { get; }

	/** If there are children, get the {@code i}th value indexed from 0. */
	public abstract BaseTree? child_at(uint i);

	/**
	 * How many children are there? If there is none, then this
	 * node represents a leaf node.
	 */
	public abstract uint child_count { get; }
}
