<?php

/**
 * One should of course NEVER try to parse HTML with regular
 * expressions, but that didn't stop me from trying at one
 * point in my life. This terrible implementation is only made
 * available because it contains some wonderfully complex
 * regular expressions.
 * 
 * http://stackoverflow.com/a/1732454
 */

class Zalgo_Html_Extractor {
    
    /**
     * Stores the tags found during the last extract() call.
     * @var array
     */
    private $_tags = null;
    
    /**
     * @return string A regular expression capable of matching
     * most HTML, XHTML and XML tags regardless of attributes and
     * content. The regexp is however designed to handle somewhat
     * welformed markup. Data more messy than valid HTML 4.01
     * transitional will probably not work 100%. This regexp
     * should be used with the preg_* functions.
     */
    private function _tagPattern() {
        return '
            /
                <\/?[a-zA-Z][-.a-zA-Z0-9:_]*\s*                    # Tag name
                    (?:\s+                                         # Whitespace before attribute name
                        (?:[a-zA-Z_][-.:a-zA-Z0-9_]*               # Attribute name
                            (?:\s*=\s*                             # Value indicator
                                (?:\'[^\']*\'|"[^"]*"|[^\'">\s]+)  # Single or double qoute enclosed or bare value
                            )?                                     # 
                        )                                          # 
                    )*                                             # 
                    \s*                                            # 
                \/?>                                               # Tag closure
            /x
        ';
    }
    
    /**
     * Feed the extractor with markup data.
     * 
     * @param string $data The data that will be handled by the
     * extractor.
     * 
     * @return array A collection of Zalgo_Html_Tag objects which
     * could be be extracted from the given data.
     */
    public function extract($data) {
        $foundTags = array();
        preg_match_all($this->_tagPattern(), $data, $foundTags);
        $foundTags = $foundTags[0];
        
        $this->_tags = array();
        foreach ($foundTags as $tag)
            $this->_tags[] = new Zalgo_Html_Tag($tag);
        
        return $this->_tags;
    }
    
    /**
     * @return array Get the elements that were extracted in the
     *               last call to extract().
     */
    public function getLastResult() {
        return $this->_tags;
    }
    
}

class Zalgo_Html_Tag {
    
    /**
     * The raw, unparsed tag as a string.
     * @var string
     */
    private $_tag = null;
    
    /**
     * The tag name.
     * @var string
     */
    private $_name = null;
    
    /**
     * The attributes that were extracted from the held tag stored
     * as key/value pairs, where the attribute name is the key and
     * its value is the value. Attributes are accessible through
     * the __get() method.
     * @var array
     */
    private $_attributes = array();
    
    /**
     * @return string A regular expression capable of matching
     * the attributes and the name of a tag. Can handle single
     * and double qouted values as well as bare/raw attribute
     * values.
     */
    private function _attrPattern() {
        return '
            /
                \s*([a-zA-Z_][-.:a-zA-Z_0-9]*)                                       # Attribute name
                (\s*=\s*(\'[^\']*\'|"[^"]*"|[-a-zA-Z0-9.\/,:;+*%?!&$\(\)_#=~@]*))?   # Value indicator and attribute value
            /x
        ';
    }
    
    /**
     * Construct a tag object from a raw HTML tag.
     * 
     * @param string $tag The tag that will be handled.
     */
    public function __construct($tag) {
        $this->_tag = $tag;
        
        $foundAttrs = array();
        preg_match_all($this->_attrPattern(), $this->_tag, $foundAttrs);
        $foundAttrs = $foundAttrs[0];
        
        // The first "attribute" is actually the name of the tag, so
        // we can store it right a way.
        // 
        $this->_name = array_shift($foundAttrs);
        
        foreach ($foundAttrs as $attr) {
            // Split the attribute into an attribute name and a value
            // and strip the qoutes, if any, from the value.
            // 
            list($name, $value) = preg_split('/\s*=\s*/x', $attr, 2);
            $value = preg_replace(array('/^("|\')?/x', '/("|\')?$/x'), '', $value, 1);
            $name = trim($name);
            
            if (!array_key_exists($name, $this->_attributes))
                $this->_attributes[$name] = $value;
        }
        
    }
    
    /**
     * @return string Get the name of this tag.
     */
    public function getName() {
        return $this->_name;
    }
    
    /**
     * Get the value of the requested attribute.
     * 
     * <code>
     * $httpEquiv = $metaTag->getAttr('http-equiv');
     * </code>
     * 
     * @param string The attribute name.
     * 
     * @return mixed Null if the requested attribute is not present
     * in the tag, otherwise the attribute value.
     */
    public function getAttr($name) {
        if (array_key_exists($name, $this->_attributes))
            return $this->_attributes[$name];
        return null;
    }
    
    /**
     * Make tag attribute values available as public class
     * members. This makes the following syntax possible:
     * <code>
     * $tag = new Zalgo_Html_Tag('<a href = "http://zalgo.se">');
     * $link = $tag->href; // Prints 'http://zalgo.se'
     * </code>
     * 
     * Use getAttr() to get attribute values when the attribute
     * contains characters which can not be a part of a PHP variable
     * name. The only exception to this is dashes, which can
     * optionally be handled as underscores when using __get():
     * 
     * <code>
     * $httpEquiv = $metaTag->http_equiv; // is the same as:
     * $httpEquiv = $metaTag->getAttr('http-equiv');
     * </code>
     * 
     * @return mixed Null if the requested attribute is not
     * present in the tag, otherwise the attribute value.
     */
    public function __get($name) {
        return $this->getAttr(str_replace('_', '-', $name));
    }
    
    /**
     * @return string The entire, unparsed tag as a string.
     * @code
     * $tag = new Zalgo_Html_Tag('<p style = "background-color: blue">');
     * echo $tag; // Prints '<p style = "background-color: blue">'
     * @endcode
     */
    public function __toString() {
        return $this->_tag;
    }
}

