--
--  Wall of sheep script for pom-ng. It dumps all the password seen.
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

output_wallofsheep = pom.output.new("wallofsheep", {
	{ "log_file", "string", "wallofsheep.log", "Log filename" },
})


function output_wallofsheep:process_http_request(evt)

	local data = evt.data

	local username = data["username"]
	local password = data["password"]

	if not username or not password then return end

	local client = data["client_addr"]
	local server = data["server_name"]
	local status = data["status"]

	password = password:sub(0, 2) .. "..."

	self.logfile:write("Found credentials via HTTP : " .. client .. " -> " .. server .. " | user : '" .. username .."', password : '" .. password .. "' (status " .. status .. ")\n")
	self.logfile:flush()

end

function output_wallofsheep:process_smtp_auth(evt)

	local data = evt.data
	local server = data["server_host"]
	if not server
	then
		server = data["server_addr"]
	end
	
	local params = data["params"]

	if not params then
		print("PARAMS not found !")
		return
	end

	local username = params["username"]
	local password = params["password"]
	local method = data["type"]

	if not username or not password then return end

	if data["success"]
	then
		status = "success"
	else
		status = "auth failure"
	end

	local client = data["client_addr"]

	password = password:sub(0, 2) .. "..."
	self.logfile:write("Found credentials via SMTP : " .. client .. " -> " .. server .. " | user : '" .. username .. "', password : '" .. password .. "', method : '" .. method .. "' (status : " .. status .. ")\n")
	self.logfile:flush()

end

function output_wallofsheep:open()

	-- Open the log file
	self.logfile = io.open(self:param_get("log_file"), "a")

	-- Listen to HTTP request event
	self:event_listen_start("http_request", nil, self.process_http_request)

	-- Listen to SMTP auth event
	self:event_listen_start("smtp_auth", nil, self.process_smtp_auth)

end

function output_wallofsheep:close()

	if self.logfile then
		self.logfile:close()
	end

	self:event_listen_stop("http_request")
	self:event_listen_stop("smtp_auth")


end

function output_wallofsheep_register()
	
	-- Register our new output
	pom.output.register(output_wallofsheep)	
end


