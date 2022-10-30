using System;
using System.Collections.Generic;
using Godot;

public static class FileUtils
{
    public static Error ReadFile(string path, out string content)
	{
		var f = new File();//create new file
		var er = f.Open(path, File.ModeFlags.Read);//open file
		
		if(er != Error.Ok)//if error, return
		{
			GD.PushError($"Error {er} while trying to read file {path}");
			content = "";
			return er;
		}
		
		content = f.GetAsText();//read text
		f.Close();//flush buffer
		return Error.Ok;
	}
	
	public static Error SaveFile(string path, string content)
	{
		var f = new File();
		var er = f.Open(path, File.ModeFlags.Write);
		
		if(er != Error.Ok)
		{
			GD.PushError($"Error {er} while trying to write to file {path}");
			return er;
		}
		
		f.StoreString(content);
		f.Close();
		return Error.Ok;
	}
	
	public static Error ListDirectoryFiles(string path, out List<string> fileList)
	{
		fileList = new List<string>();
		var dir = new Directory();
		var er = dir.Open(path);
		if(er != Error.Ok)
		{
			GD.PushError($"Error {er} while trying to open directory {path}");
			return er;
		}
		
		dir.ListDirBegin(true);
		string file;
		while((file = dir.GetNext()) != "") if(!dir.CurrentIsDir())
			fileList.Add(file);
		dir.ListDirEnd();
		return Error.Ok;
	}
}