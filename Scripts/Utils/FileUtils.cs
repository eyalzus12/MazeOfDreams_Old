using System;
using System.Collections.Generic;
using Godot;

public static class FileUtils
{
    public static Error ReadFile(string path, out string content)
	{
		var f = FileAccess.Open(path, FileAccess.ModeFlags.Read);//open file for reading
		var er = FileAccess.GetOpenError();
		
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
		var f = FileAccess.Open(path, FileAccess.ModeFlags.Write);
		var er = FileAccess.GetOpenError();
		if(er != Error.Ok)//if error, return
		{
			GD.PushError($"Error {er} while trying to write to file {path}");
			return er;
		}
		
		f.StoreString(content);//write text
		f.Close();//flush buffer
		return Error.Ok;
	}
	
	public static Error ListDirectoryFiles(string path, out List<string> fileList)
	{
		fileList = new List<string>();//init file list
		var dir = DirAccess.Open(path);//open dir
		var er = DirAccess.GetOpenError();
		if(er != Error.Ok)//if error, return
		{
			GD.PushError($"Error {er} while trying to open directory {path}");
			return er;
		}
		
		dir.ListDirBegin();//start dir file list iteration
		string file;
		while((file = dir.GetNext()) != "") if(!dir.CurrentIsDir())//go over non-dir files
			fileList.Add(file);//add to list
		dir.ListDirEnd();//flush buffer
		return Error.Ok;
	}
}