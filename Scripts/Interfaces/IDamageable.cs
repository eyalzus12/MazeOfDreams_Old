using System;
using Godot;

public interface IDamageable
{
    float Health { get; set; }

    void UpdateHealthBar();
}