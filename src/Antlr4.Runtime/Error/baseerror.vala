/* baseerror.vala
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
 * Because Vala doesn't have traditional exceptions,
 * but rather uses errordomains, and ANTLR errors
 * use a lot of additional info, I created this
 * class as a base wrapper, that contains the info,
 * and throws a catchable exception.
 */
public abstract class Antlr4.Runtime.Error.BaseError : GLib.Object
{
    public ANTLRError err { get; protected set; default = new ANTLRError.ERROR(""); }

    protected BaseError(ANTLRError? err = null)
    {
        this.err = err ?? this.err;
    }

    protected BaseError.with_message(string message, ...)
    {
        this.err = new ANTLRError.ERROR(message.vprintf(va_list()));
    }

    public void throw() throws ANTLRError
    {
        throw err;
    }
}

/**
 * The underlying error thrown with
 * {@link Antlr4.Runtime.Error.BaseError}
 */
public errordomain Antlr4.Runtime.Error.ANTLRError
{
    /**
     * Any kind of error thrown, as this
     * is just a wrapped error.
     */
    ERROR;
}
