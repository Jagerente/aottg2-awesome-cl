component RigidbodyBuiltin
{
    Mass = 1.0;
    Gravity = Vector3(0.0, -20.0, 0.0);
    FreezeRotation = false;
    Interpolate = false;

    function Init()
    {
        self.MapObject.AddBuiltinComponent("Rigidbody", self.Mass, self.Gravity, self.FreezeRotation, self.Interpolate);
    }

    function SetVelocity(velocity)
    {
        self.MapObject.UpdateBuiltinComponent("Rigidbody", "SetVelocity", velocity);
    }

    function AddForce(force)
    {
        self.MapObject.UpdateBuiltinComponent("Rigidbody", "AddForce", force);
    }

    function AddForceWithMode(force, mode)
    {
        self.MapObject.UpdateBuiltinComponent("Rigidbody", "AddForce", force, mode);
    }

    function AddForceWithModeAtPoint(force, point, mode)
    {
        self.MapObject.UpdateBuiltinComponent("Rigidbody", "AddForce", force, mode, point);
    }

    function AddTorque(force, mode)
    {
        self.MapObject.UpdateBuiltinComponent("Rigidbody", "AddTorque", force, mode);
    }

    # @return Vector3
    function GetVelocity()
    {
        return self.MapObject.ReadBuiltinComponent("Rigidbody", "Velocity");
    }

    # @return Vector3
    function GetAngularVelocity()
    {
        return self.MapObject.ReadBuiltinComponent("Rigidbody", "AngularVelocity");
    }
}
