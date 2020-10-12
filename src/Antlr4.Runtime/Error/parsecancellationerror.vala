/* parsecancellationerror.vala
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
 * This exception is thrown to cancel a parsing operation. This exception does
 * not extend {@link RecognitionException}, allowing it to bypass the standard
 * error recovery mechanisms. {@link BailErrorStrategy} throws this exception in
 * response to a parse error.
 *
 * @author Sam Harwell
 */
public errordomain Antlr4.Runtime.Error.ParseCancellationException
{
    PARSE_CANCELLED;

    public static ParseCancellationException from(string message = "", GLib.Error? cause = null)
    {
        return cause == null ?
              new ParseCancellationException.PARSE_CANCELLED(message)
            : new ParseCancellationException.PARSE_CANCELLED("%s caused by %s: '%s'".printf(message, cause.domain.to_string(), cause.message))
            ;
    }
}
