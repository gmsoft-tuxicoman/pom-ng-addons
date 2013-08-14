--
--  Log searches performed over HTTP.
--  Copyright (C) 2013 Guy Martin <gmsoft@tuxicoman.be>
--
--  This program is free software; you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published by
--  the Free Software Foundation; either version 2 of the License, or
--  (at your option) any later version.
--
--  This program is distributed in the hope that it will be useful,
--  but WITHOUT ANY WARRANTY; without even the implied warranty of
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--  GNU General Public License for more details.
--
--  You should have received a copy of the GNU General Public License
--  along with this program; if not, write to the Free Software
--  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
--


require "pom"

output_http_searches = pom.output.new("http_searches", {
	{ "log_file", "string", "http_searches.log", "Log filename" },
	{ "match", "string", "[&?]q=([^&]*)", "Lua pattern to match" }
})

function output_http_searches:process_request(evt)

	local data = evt.data

	local url = data["url"]

	if not url then
		return
	end

	local match = string.match(url, self.match)
	if not match then
		return
	end

	local server = data["server_name"]
	local client = data["client_addr"]

	self.logfile:write("Client " .. client .. " searched for \"" .. match .. "\" on " .. server .. "\n")
	self.logfile:flush()

end

function output_http_searches:open()

	-- Open the log file
	self.logfile = io.open(self:param_get("log_file"), "a")

	-- Listen to HTTP request event
	self:event_listen_start("http_request", nil, self.process_request)

	-- Copy the match parameter for faster execution
	self.match = self:param_get("match")

end

function output_http_searches:close()

	if self.logfile then
		self.logfile:close()
	end

	self:event_listen_stop("http_request")


end

function output_http_searches_register()
	
	-- Register our new output
	pom.output.register(output_http_searches)	
end


