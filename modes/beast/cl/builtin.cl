component IRigidbody
{
    Mass = 1.0;
    Gravity = Vector3(0.0, -20.0, 0.0);
    FreezeRotation = false;
    Interpolate = false;

    function Init(){}

    # @param velocity Vector3
    function SetVelocity(velocity){}

    # @param force Vector3
    function AddForce(force){}

    # @param force Vector3
    # @param mode string
    function AddForceWithMode(force, mode){}

    # @param force Vector3
    # @param point Vector3
    # @param mode string
    function AddForceWithModeAtPoint(force, point, mode){}

    # @param force Vector3
    # @param mode string
    function AddTorque(force, mode){}

    # @return Vector3
    function GetVelocity(){}

    # @return Vector3
    function GetAngularVelocity(){}
}
