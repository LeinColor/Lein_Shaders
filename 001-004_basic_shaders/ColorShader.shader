Shader "Lein's Shader/ColorShader"
{
    // Properties show values that can be controlled on the Unity Editor.
    //
    // The format is as follows:
    //   variable_name (var1, var2) [=default value]
    //
    // variable_name    : variable name. you must match variable name with CGProgram's variable name.
    // var1             : property name to be displayed within Unity. it's String type.
    // var2             : specify how to control value. for example, if you want to use color picker, pass Color parameter.
    // [=default value] : initial value. it's omitable.
    Properties
    {
        _Color ("Tint", Color) = (1,1,1,1) // r, g, b, a = (1, 1, 1, 1) = White
    }
    
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard fullforwardshadows

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        sampler2D _MainTex;

        struct Input
        {
            float2 uv_MainTex;
        };

        half _Glossiness;
        half _Metallic;
        fixed4 _Color;

        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            // Albedo comes from a texture tinted by color
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
            o.Albedo = c.rgb;
            // Metallic and smoothness come from slider variables
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
