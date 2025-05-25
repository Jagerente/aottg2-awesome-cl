extension HTML
{
    # @param str string
    # @param color string
    # @return string
    function Color(str, color)
    {
        return "<color=#" + color + ">" + str + "</color>";
    }
    
    # @param str string
    # @param size int
    # @return string
    function Size(str, size)
    {
        return "<size=" + size + ">" + str + "</size>";
    }
    
    # @param str string
    # @return string
    function Bold(str)
    {
        return "<b>" + str + "</b>";
    }
    
    # @param str string
    # @return string
    function Italic(str)
    {
        return "<i>" + str + "</i>";
    }
}
