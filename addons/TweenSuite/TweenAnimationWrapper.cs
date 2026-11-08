using System;
using Godot;

namespace Godot.TweenSuite;

/// <summary>
/// <para>TweenAnimationWrapper is a <see cref="Godot.Resource"/> that serves as bridge between a GDScript TweenSuite's TweenAnimation resource and your C# code. Useful to start a data driven <see cref="Godot.Tween"/> directly in your code.</para>
/// <para>You only have to call <c>@TweenAnimationWrapper.Setup(rootNode)</c> to create a <see cref="Godot.Tween"/> and setup any <see cref="Godot.Tweener"/> defined in the linked TweenAnimation.</para>
/// </summary>
[GlobalClass]
public partial class TweenAnimationWrapper : Resource
{
    /// <summary>
    /// <para>Link to your GDScript TweenSuite's TweenAnimation resource file.</para>
    /// </summary>
    [Export(PropertyHint.ResourceType, "TweenAnimation")]
    public Resource AnimationResource{ get; set; }

    // Method bridge
    private readonly StringName _applyToTweenMethod = new StringName("apply_to_tween");
    private readonly StringName _setParameterMethod = new StringName("set_parameter");
    private readonly StringName _removeParameterMethod = new StringName("remove_parameter");
    private readonly StringName _removeAllParametersMethod = new StringName("remove_all_parameters");
    private readonly StringName _getParameterMethod = new StringName("get_parameter");
    
    /// <summary>
    /// <para>Creates a <see cref="Godot.Tween"/> and setups it with your linked TweenAnimation.</para>
    /// <para> <b>rootNode</b> is the root <see cref="Godot.Node"/> you want to tween.</para>
    /// <para> <b>bindToNode</b> will bind your Tween to your Node, killing it if your node exit the tree or is freed.</para>
    /// <para><code>
    /// public partial class YourNode : Node
    /// {
    ///    [Export] public TweenAnimationWrapper YourAnimation { get; set; }
    /// 
    ///     public void StartTweenAnimation()
    ///     {
    ///         if (YourAnimation != null)
    ///         {
    ///             Tween myTween = YourAnimation.Setup(this, true);
    ///             // Do whatever you want with the tween as usual
    ///         }
    ///     }
    /// }
    /// </code></para>
    /// </summary>
    public Tween Setup(Node rootNode, bool bindToNode = false)
    {
        if (AnimationResource != null && rootNode != null && rootNode.IsInsideTree())
        {
            Tween tween = rootNode.GetTree().CreateTween();
            if (bindToNode)
            {
                tween.BindNode(rootNode);
            }
            AnimationResource.Call(_applyToTweenMethod, tween, rootNode);
            return tween;
        }
        return null;
    }
    
    /// <summary>
    /// <para>Setups a <see cref="Godot.Tween"/> on a <see cref="Godot.Node"/> with your linked TweenAnimation.</para>
    /// <para> <b>rootNode</b> is the root Node you want to tween.</para>
    /// <para> <b>tween</b> the tween you want to setup with your TweenAnimation.</para>
    /// </summary>
    public bool ApplyToTween(Node rootNode, Tween tween)
    {
        if (AnimationResource != null && rootNode != null && tween != null)
        {
            AnimationResource.Call(_applyToTweenMethod, tween, rootNode);
            return true;
        }
        return false;
    }
    
    /// <summary>
    /// <para>Sets a runtime parameter on the animation. Used for code defined values.</para>
    /// <para>Setting a null value will remove the parameter, equivalent to RemoveParameter().</para>
    /// <para> <b>name</b> is the name of the parameter. Can be accessed in the editor via "%name" in the variant fields.</para>
    /// <para> <b>value</b> your custom value.</para>
    /// </summary>
    public bool SetParameter(StringName name, Variant value)
    {
        if (AnimationResource != null && name != null)
        {
            AnimationResource.Call(_setParameterMethod, name, value);
            return true;
        }
        return false;
    }
    
    /// <summary>
    /// <para>Removes a runtime parameter on the animation.</para>
    /// <para> <b>name</b> is the name of the parameter.</para>
    /// </summary>
    public bool RemoveParameter(StringName name)
    {
        if (AnimationResource != null && name != null)
        {
            AnimationResource.Call(_removeParameterMethod, name);
            return true;
        }
        return false;
    }
    
    /// <summary>
    /// <para>Removes all parameters on the animation.</para>
    /// </summary>
    public bool RemoveAllParameters()
    {
        if (AnimationResource != null)
        {
            AnimationResource.Call(_removeAllParametersMethod);
            return true;
        }
        return false;
    }
    
    /// <summary>
    /// <para>Removes all parameters on the animation.</para>
    /// </summary>
    public Variant GetParameter(StringName name)
    {
        if (AnimationResource != null)
        {
            return AnimationResource.Call(_getParameterMethod, name);
        }
        return default;
    }
}