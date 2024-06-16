<?
/* Google Cracker
 *
 * Utiliza o Google para procurar hashes e informar se a senha é trivial ou não.
 * Você precisa da chave disponível em http://www.google.com/apis/
 *
 * Ex.: $ cat passwords.txt
 * 5f4dcc3b5aa765d61d8327deb882cf99
 *
 * $ php googlecracker.php
 * Password "5f4dcc3b5aa765d61d8327deb882cf99" is trivial
 * quick: Hash: 5f4dcc3b5aa765d61d8327deb882cf99 password: "password"
 *
 * Narcotic
 */

	error_reporting(E_ALL);
	set_time_limit(0);
	
class GoogleCracker {
	
		private $client;
		private $key;
		private $passwordList;
		private $hashAlgorithm;
		private $searchResults;
		
		public function __construct($key) {
			$this->key = $key;
			$this->words = array();
			$this->passwordList  = array();
			$this->searchResults = array();
			$this->hashAlgorithm = 'md5';

			$this->client = new SoapClient('http://api.google.com/GoogleSearch.wsdl');
		}
		
		private function googleSearch($word) {
			return $this->client->doGoogleSearch($this->key, $word, 0, 10, true, "" ,false, '', "UTF-8", "UTF-8" );
		}

		public function googling() {
		
			$list = $this->passwordList;
			$result = array();
	
			foreach($list as $password) {
				/* get the first 10 results with the word $password */
				$search = $this->googleSearch($password);
				
				/* nothing found */
				if($search->estimatedTotalResultsCount == 0)
					echo 'Password ' . $password . " is not trivial\n";
				else {
					echo 'Password "' . $password . "\" is trivial\n";
					
					foreach($search->resultElements as $element) {
						$result[] = array('url' => $element->URL,
									'snippet' => $element->snippet);
					}
				}
			}
			
			$this->searchResults = $result;
			return $result;
		}

		/* load a file with the passwords separated by new line */
		public function loadPasswords($filename) {
			$list = file($filename);
			foreach($list as $pass) {
				$pass = str_replace("\r", '', $pass);
				$pass = str_replace("\n", '', $pass);
				$this->passwordList[] = $pass;
			}
		}
		
		/* get only the snippets to cracking password */
		public function quickCrack() {
			$words = array();
			
			foreach($this->searchResults as $result) {
				$words = array_merge($words, explode(' ', $result['snippet']));				
			}
			
			$words = array_unique($words);
			return $this->crack($words);
		}
		
		public function deepCrack() {
			$words = array();
			
			foreach($this->searchResults as $result) {
				$lines = file($result['url']);
				
				foreach($lines as $line) {
					$words = array_merge($words, explode(' ', $line));
				}
			}
			
			$words = array_unique($words);
			return $this->crack($words);
		}
				
		private function crack($words) {
			$hashes = array();
			$return = array();
			
			/* create a array with the pair hash/word */			
			foreach($words as $word) {
				$hash = $this->hashFunction($word);
				$hashes[$hash] = $word;
			}
			
			foreach($this->passwordList as $pass) {
				/* cracked ? */
				if(isset($hashes[$pass])) {
					echo 'Hash: ' . $pass . ' password: "' . $hashes[$pass] . "\"\n";
					$return[$pass] = $hashes[$pass];
				}
			}
			
			return $return;
		}
		
		public function setHashAlgorithm($func) {
			$this->hashAlgorithm = $func;
		}
		
		private function hashFunction($word) {
			$func = $this->hashAlgorithm;
			return $func($word);
		}
}
	echo '<pre>';
	/* example */
	$key    = 'XXXXXXXXXXXXXXXXXXXXXXXXXX';   //coloque aqui a sua key
	$crack  = new GoogleCracker($key);
	
	$crack->loadPasswords('passwords.txt');
	$crack->googling();
	
	echo 'quick: ';
	$crack->quickCrack();
	
	echo 'deep: ';
	$crack->deepCrack();
	
	echo '</pre>';
?>
