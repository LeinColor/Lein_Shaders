// 쉐이더의 기본 작성법은 아래 링크를 참조하세요.
// https://docs.unity3d.com/Manual/SL-Reference.html

Shader "Lein's Shader/ColorShader"      // 유니티의 Shader 메뉴에서 표시될 이름을 지정합니다.
{
    // 유니티 에디터 내에서 값을 변경하고 싶다면 속성들을 정의해주어야 합니다.
    //   변수명 ("레이블명", 속성타입) [= 기본값]
    
    // 1. 변수명 : CGPROGRAM 구문 내에 존재하는 변수명이어야 합니다.
    // 2. 레이블명 : 유니티 에디터 내에서 속성에 표시될 이름을 적습니다.
    // 3. 속성타입 : 값을 어떤 형식으로 제어할 지 정의해줍니다.
    //              예를 들어, 색상이라면 Color를 적었을 때 Colorpicker가 호출되며,
    //              밝기를 값으로 조절해야 하는 형식이라면 Range(a, b) 로 최솟값~최댓값을 지정해줄 수 있습니다.
    // 4. [= 기본값] : 초기값을 지정해주는 부분이며, 생략해도 됩니다.

    // 속성 입력의 예시는 다음과 같습니다.

    // Numbers and Sliders (값 입력 및 슬라이더를 통한 제어)
    // name ("display name", Range (min, max)) = number
    // name ("display name", Float) = number
    // name ("display name", Int) = number

    // Colors and Vectors (색상과 벡터)
    // name ("display name", Color) = (number,number,number,number)
    // name ("display name", Vector) = (number,number,number,number)

    // Textures (텍스쳐)
    // name ("display name", 2D) = "defaulttexture" {}
    // name ("display name", Cube) = "defaulttexture" {}
    // name ("display name", 3D) = "defaulttexture" {}

    // 자세한 내용은 https://docs.unity3d.com/kr/530/Manual/SL-Properties.html 를 참조하세요.
    Properties
    {
        _Color ("Tint", Color) = (1,1,1,1) // r, g, b, a = (1, 1, 1, 1) = "White"
    }
    
    // 각 쉐이더는 SubShader들이 모여 구성됩니다. 적어도 하나는 필요하다는 의미입니다.
    // 쉐이더를 로드할 때, 유니티는 여러 개의 SubShader 중에서 사용자의 하드웨어에서 동작할 수 있는 첫 번째 SubShader를 선택합니다.
    // 최상위 품질을 제공하는 SubShader, 중간 품질의 SubShader, 최하급 품질의 SubShader 등 여러 개를 작성한다고 생각하시면 편합니다.
    // 사용자마다 하드웨어 성능이 다르니까 이러한 다양성을 위해 여러 개의 SubShader를 구성할 수 있도록 해둔 것이죠.
    // https://docs.unity3d.com/kr/530/Manual/SL-SubShader.html

    // 만약 지원되는 SubShader가 없는 경우, Unity는 Fallback Shader를 적용합니다.
    // https://docs.unity3d.com/kr/530/Manual/SL-Fallback.html
    SubShader
    {
        // Pass 블록은 오브젝트의 지오메트리를 한 번만 렌더링하도록 합니다. 지금은 다소 어려울 수 있는 내용이므로 가볍게 넘어가줍시다.
        Pass
        {
            // 쉐이더 코드가 본격적으로 작성되는 부분입니다.
            CGPROGRAM
            
            // 유니티에서 제공하는 쉐이더 개발에 유용한 함수들을 사용하기 위해 적어줍니다.
            #include "UnityCG.cginc"

            // 컴파일될 부분을 지정합니다. 간단히 설명하자면 다음과 같습니다.
            // #pragma vertex 함수명 : 해당 함수를 vertex shader로 컴파일해라
            // #pragma fragment 함수명 : 해당 함수를 fragment shader로 컴파일해라
            // 따라서 아래는 vert 함수가 vertex shader, frag 함수가 fragment shader로 컴파일 되는 것입니다.
            // 자세한 내용은 https://docs.unity3d.com/Manual/SL-ShaderPrograms.html 요기를 참조하세요.
            #pragma vertex vert
            #pragma fragment frag

            // material에 적용할 색상 변수를 선언합니다.
            fixed4 _Color;

            // vertex shader로 읽을 mesh data들을 정의합니다.
            struct appdata {
                float4 vertex : POSITION;
                fixed4 color : COLOR;
            };

            // fragment shader에서 처리할 데이터들을 정의합니다. (vertex shader에서 처리된 데이터들이 패스되고, 이는 rasterizer에 의해 보간(interpolation)됩니다.)
            struct v2f {
                float4 pos : SV_POSITION;
                fixed4 color : COLOR;
            };

            // vertex shader에서 처리할 함수입니다.
            // vertex shader는 오브젝트를 구성하는 꼭짓점들에 대해 처리한다고 보시면 됩니다.
            v2f vert(appdata v)
            {
                // fragment shader로 넘길 구조체 데이터를 선언합니다.
                v2f o;

                // object space를 clip space로 변환합니다. (오브젝트 좌표계에서 월드 좌표계로 변환해준다고 보시면 됩니다.)
                // 이 함수가 있어야 오브젝트가 렌더링되는 위치가 제대로 나타납니다.
                o.pos = UnityObjectToClipPos(v.vertex);

                // 속성에서 제어 가능한 _Color를 대입해줌에 따라 사용자가 설정한 색상으로 변경됩니다.
                o.color = _Color;

                // return문을 통해 다음 절차인 fragment shader로 보냅니다.
                // vertex shader의 역할은 여기까지 제대로 수행한 것이죠.
                return o;
            }

            // fragment shader에서 처리할 함수입니다.
            // vertex shader가 꼭짓점에 대해서 처리한다면, fragment shader는 그 면을 이루는 모든 픽셀들에 대해 처리하는 부분이라고 보시면 됩니다.
            // 아무래도 꼭짓점보단 면을 이루고 있는 픽셀들의 수가 더 많을테니 더 무겁겠죠? 최적화를 위해 함수를 신중히 작성해주어야 한다고 볼 수 있습니다.

            // 뒤의 : SV_TARGET은 Fragment shader output semantics라고 하는데, 여기서는 fixed4 단일값 하나만 반환하므로 SV_TARGET이라고 써줍니다.
            // SV_TARGET은 SV_TARGET0와 같으며, Multiple render targets을 지정할 땐 SV_TARGET1, SV_TARGET2, ... 이런식으로도 지정해줄 수 있습니다.
            // 지금은 이해하기 어려운 내용이므로 가볍게 넘어가셔도 좋습니다.
            // https://docs.unity3d.com/Manual/SL-ShaderSemantics.html
            fixed4 frag(v2f i) : SV_TARGET
            {
                // 이번 튜토리얼 쉐이더는 단순히 색상만 입히므로, 여기서는 딱히 가공할 게 없습니다.
                // vertex shader에서 넘겨받은 데이터들을 그대로 반환해줍니다.
                
                // vertex shader에서 꼭지점에만 색상을 입힌 것인데 면에 색상이 입혀지는 이유는 이 과정에서 알아서 보간(interpolation)해주기 때문입니다.
                // 보간이란, 쉽게 설명하자면 그라데이션 색상을 생각해보시면 됩니다.
                // 여기서는 모든 꼭지점 부분이 _Color 색상으로 동일하므로 단일 색상으로 표현되는 것처럼 보입니다만,
                // 각 꼭지점에 다른 색상들로 지정해주면 그라데이션 색상으로 보이게 될 겁니다.
                return i.color;
            }

            // 쉐이더 코드가 끝나는 부분입니다.
            ENDCG
        }
    }

    // FallBack은 SubShader를 실행할 수 없는 환경일 경우 최후에 실행될 쉐이더를 적용합니다.
    // Fallback "쉐이더명" 같이 작성해주시면 되겠습니다.

    // 여기선 대신 적용할 쉐이더가 딱히 없다고 생각되어 Off로 해두었습니다.
    FallBack Off
}
