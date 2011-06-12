<?php
class Configuration
{
  private $configFile = '/home/etl/dwh/.kettle/kettle.properties';

  private $items = array();

  function __construct() { $this->parse(); }

  function __get($id) { return $this->items[ $id ]; }

  function parse()
  {
    $fh = fopen( $this->configFile, 'r' );
    while( $l = fgets( $fh ) )
    {
      if ( preg_match( '/^#/', $l ) == false )
      {
        preg_match('/(?P<key>.*)=(?P<val>.*)/', $l, $found );
		if(count($found)>3)
		{
			$this->items[ trim($found[1]) ] = trim($found[2]);
		}
      }
    }
    fclose( $fh );
  }
}

$CONF = new Configuration();
?>