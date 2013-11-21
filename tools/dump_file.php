<?php
error_reporting(E_ALL);
require("nbt.class.php");
$nbt = new nbt();
$nbt->verbose = true;
$nbt->loadFile($argv[1]);
print(json_encode($nbt->root[0]));
?>

