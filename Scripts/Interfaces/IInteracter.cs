using System;
using Godot;

public interface IInteracter
{
    IInteractable CurrentInteractable{get; set;}
    
    void CheckInteraction();
}