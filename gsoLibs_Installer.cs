using System;
using System.IO;
using System.Net;

namespace gsoLibs_Installer
{
	class Program
	{
		static string DownloadFileString(string link)
		{
			string result = "";
			using (WebClient webClient = new WebClient())
			{
				result = webClient.DownloadString(link);
			}
			return result;
		}
		
		public static void Main(string[] args)
		{
			
			
			
			// Paths
			string appDataDir = Environment.GetFolderPath(Environment.SpecialFolder.ApplicationData);
			string mimeDll = appDataDir + "\\GamingOnSteroids\\LOL\\Scripts\\Common\\mime\\core.dll";
			string socketDll = appDataDir + "\\GamingOnSteroids\\LOL\\Scripts\\Common\\socket\\core.dll";
			string mimeDir = appDataDir + "\\GamingOnSteroids\\LOLEXT\\Scripts\\Common\\mime";
			string socketDir = appDataDir + "\\GamingOnSteroids\\LOLEXT\\Scripts\\Common\\socket";
			string gsoDir = appDataDir + "\\GamingOnSteroids\\LOLEXT\\Scripts\\Common\\gsoLibs";
			string luaDir = appDataDir + "\\GamingOnSteroids\\LOLEXT\\Scripts\\Common\\gsoLibs\\lua";
			string luaSocketDir = appDataDir + "\\GamingOnSteroids\\LOLEXT\\Scripts\\Common\\gsoLibs\\lua\\socket";
			Directory.CreateDirectory(appDataDir + "\\GamingOnSteroids\\LOLEXT\\Scripts");
			Directory.CreateDirectory(appDataDir + "\\GamingOnSteroids\\LOLEXT\\Scripts\\Common");
			Directory.CreateDirectory(mimeDir);
			Directory.CreateDirectory(socketDir);
			Directory.CreateDirectory(gsoDir);
			Directory.CreateDirectory(luaDir);
			Directory.CreateDirectory(luaSocketDir);
			
			
			
			// Installer:
			Console.WriteLine(Environment.NewLine + "GsoLibs Installer:");
			Console.WriteLine(Environment.NewLine + "Please wait...");
			
			
			
			// Copy LuaSocket dll's:
			File.Copy(mimeDll, mimeDir + "\\core.dll", true);
			File.Copy(socketDll, socketDir + "\\core.dll", true);
			
			
			
			// Download GsoLibs files:
			
			const string testloader = @"https://raw.githubusercontent.com/gamsteron/GoSExt/master/testLoader.lua";
			File.WriteAllText(appDataDir + "\\GamingOnSteroids\\LOLEXT\\Scripts\\testLoader.lua", Program.DownloadFileString(testloader));
			
			
			
			const string gsoLibs_activator = @"https://raw.githubusercontent.com/gamsteron/gsoLibs/master/Activator.lua";
			File.WriteAllText(gsoDir + "\\Activator.lua", Program.DownloadFileString(gsoLibs_activator));
			
			const string gsoLibs_autoupdate = @"https://raw.githubusercontent.com/gamsteron/gsoLibs/master/AutoUpdate.lua";
			File.WriteAllText(gsoDir + "\\AutoUpdate.lua", Program.DownloadFileString(gsoLibs_autoupdate));
			
			const string gsoLibs_cursor = @"https://raw.githubusercontent.com/gamsteron/gsoLibs/master/Cursor.lua";
			File.WriteAllText(gsoDir + "\\Cursor.lua", Program.DownloadFileString(gsoLibs_cursor));
			
			const string gsoLibs_farm = @"https://raw.githubusercontent.com/gamsteron/gsoLibs/master/Farm.lua";
			File.WriteAllText(gsoDir + "\\Farm.lua", Program.DownloadFileString(gsoLibs_farm));
			
			const string gsoLibs_libloader = @"https://raw.githubusercontent.com/gamsteron/gsoLibs/master/LibLoader.lua";
			File.WriteAllText(gsoDir + "\\LibLoader.lua", Program.DownloadFileString(gsoLibs_libloader));
			
			const string gsoLibs_objectmanager = @"https://raw.githubusercontent.com/gamsteron/gsoLibs/master/ObjectManager.lua";
			File.WriteAllText(gsoDir + "\\ObjectManager.lua", Program.DownloadFileString(gsoLibs_objectmanager));
			
			const string gsoLibs_orbwalker = @"https://raw.githubusercontent.com/gamsteron/gsoLibs/master/Orbwalker.lua";
			File.WriteAllText(gsoDir + "\\Orbwalker.lua", Program.DownloadFileString(gsoLibs_orbwalker));
			
			const string gsoLibs_prediction = @"https://raw.githubusercontent.com/gamsteron/gsoLibs/master/Prediction.lua";
			File.WriteAllText(gsoDir + "\\Prediction.lua", Program.DownloadFileString(gsoLibs_prediction));
			
			const string gsoLibs_spell = @"https://raw.githubusercontent.com/gamsteron/gsoLibs/master/Spell.lua";
			File.WriteAllText(gsoDir + "\\Spell.lua", Program.DownloadFileString(gsoLibs_spell));
			
			const string gsoLibs_ts = @"https://raw.githubusercontent.com/gamsteron/gsoLibs/master/TS.lua";
			File.WriteAllText(gsoDir + "\\TS.lua", Program.DownloadFileString(gsoLibs_ts));
			
			const string gsoLibs_utilities = @"https://raw.githubusercontent.com/gamsteron/gsoLibs/master/Utilities.lua";
			File.WriteAllText(gsoDir + "\\Utilities.lua", Program.DownloadFileString(gsoLibs_utilities));
			
			const string gsoLibs_gsosdk = @"https://raw.githubusercontent.com/gamsteron/gsoLibs/master/gsoSDK.lua";
			File.WriteAllText(gsoDir + "\\gsoSDK.lua", Program.DownloadFileString(gsoLibs_gsosdk));
			
			
			
			const string gsoLibs_lua_socket = @"https://raw.githubusercontent.com/gamsteron/gsoLibs/master/lua/socket.lua";
			File.WriteAllText(luaDir + "\\socket.lua", Program.DownloadFileString(gsoLibs_lua_socket));
			
			const string gsoLibs_lua_mime = @"https://raw.githubusercontent.com/gamsteron/gsoLibs/master/lua/mime.lua";
			File.WriteAllText(luaDir + "\\mime.lua", Program.DownloadFileString(gsoLibs_lua_mime));
			
			const string gsoLibs_lua_ltn12 = @"https://raw.githubusercontent.com/gamsteron/gsoLibs/master/lua/ltn12.lua";
			File.WriteAllText(luaDir + "\\ltn12.lua", Program.DownloadFileString(gsoLibs_lua_ltn12));
			
			
			
			const string gsoLibs_lua_socket_ftp = @"https://raw.githubusercontent.com/gamsteron/gsoLibs/master/lua/socket/ftp.lua";
			File.WriteAllText(luaSocketDir + "\\ftp.lua", Program.DownloadFileString(gsoLibs_lua_socket_ftp));
			
			const string gsoLibs_lua_socket_headers = @"https://raw.githubusercontent.com/gamsteron/gsoLibs/master/lua/socket/headers.lua";
			File.WriteAllText(luaSocketDir + "\\headers.lua", Program.DownloadFileString(gsoLibs_lua_socket_headers));
			
			const string gsoLibs_lua_socket_http = @"https://raw.githubusercontent.com/gamsteron/gsoLibs/master/lua/socket/http.lua";
			File.WriteAllText(luaSocketDir + "\\http.lua", Program.DownloadFileString(gsoLibs_lua_socket_http));
			
			const string gsoLibs_lua_socket_smtp = @"https://raw.githubusercontent.com/gamsteron/gsoLibs/master/lua/socket/smtp.lua";
			File.WriteAllText(luaSocketDir + "\\smtp.lua", Program.DownloadFileString(gsoLibs_lua_socket_smtp));
			
			const string gsoLibs_lua_socket_tp = @"https://raw.githubusercontent.com/gamsteron/gsoLibs/master/lua/socket/tp.lua";
			File.WriteAllText(luaSocketDir + "\\tp.lua", Program.DownloadFileString(gsoLibs_lua_socket_tp));
			
			const string gsoLibs_lua_socket_url = @"https://raw.githubusercontent.com/gamsteron/gsoLibs/master/lua/socket/url.lua";
			File.WriteAllText(luaSocketDir + "\\url.lua", Program.DownloadFileString(gsoLibs_lua_socket_url));
			
			
			
			// End:
			Console.Clear();
			Console.WriteLine(Environment.NewLine + "GsoLibs Installer:");
			Console.WriteLine(Environment.NewLine + Environment.NewLine + Environment.NewLine + "Download complete. Press any key to continue . . . ");
			Console.ReadKey(true);
			
		}
	}
}
