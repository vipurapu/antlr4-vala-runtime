/* logmanager.vala
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

public class Antlr4.Runtime.Misc.LogManager : GLib.Object
{
    protected class Record : GLib.Object
    {
		internal string component;
		internal string msg;

		public string to_string()
		{
            StringBuilder buf = new StringBuilder();
            buf.append(new DateTime.now_local().format("%Y-%m-%d-%H.%M.%S"));
            buf.append(": ");
            if (component != null) buf.append(component);
            buf.append(" ");
            buf.append(msg);
            return buf.str;
		}
	}

	protected Gee.List<Record> records;

	public void log(string msg, string? component = null)
	{
		Record r = new Record();
		r.component = component ?? "";
		r.msg = msg;
		if (records == null)
			records = new Gee.ArrayList<Record>();
		records.add(r);
	}

    public void save(string? filename = null) throws GLib.Error
    {
        if (filename == null) save0();
        else
        {
            File f = File.new_for_path(filename);
            OutputStream stream = f.create_readwrite(FileCreateFlags.PRIVATE).output_stream;
            try
            {
                stream.write(to_string().data);
            }
            catch (GLib.Error e)
            {
                warning("Error writing log data: %s", e.message);
            }
            stream.close();
        }
    }

    private string save0() throws GLib.Error
    {
        string dir = ".";
        string default_filename =
            dir + "/antlr-" +
            new DateTime.now_local().format("%Y-%m-%d-%H.%M.%S") + ".log";
        save(default_filename);
        return default_filename;
    }

    public string to_string()
    {
        if (records == null) return "";
        StringBuilder buf = new StringBuilder();
        foreach (Record r in records)
        {
            buf.append(r.to_string());
            buf.append("\n");
        }
        return buf.str;
    }

    public static int main(string[] args)
    {
        LogManager mgr = new LogManager();
        mgr.log("atn", "test msg");
        mgr.log("dfa", "test msg 2");
        stdout.printf("%s\n", mgr.to_string());
        try
        {
            mgr.save();
        }
        catch (GLib.Error e)
        {
            stdout.printf("Error: %s", e.message);
        }
        return 0;
    }
}
