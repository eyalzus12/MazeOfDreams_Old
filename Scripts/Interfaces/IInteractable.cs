using System;
using Godot;

public interface IInteractable
{
    //need Interacted signal, but interface doesn't let me

    Area2D InteractionArea{get; set;}

    int InteractionPriority{get; set;}

    void InitInteractionArea();

    void OnAreaBodyEnter(Node2D n);

    void OnAreaBodyExit(Node2D n);

    void LoopAreaCheck();

    void OnInteract(IInteracter ii);
}