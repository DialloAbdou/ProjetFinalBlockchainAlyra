 pragma solidity ^0.6.8;
 pragma experimental ABIEncoderV2;
 import "@openzeppelin/contracts/math/SafeMath.sol";
 import "@openzeppelin/contracts/token/ERC720/ERC720.sol";

contract Donation{
     using SafeMath for uint256;
    
    struct Proposition {
        uint256 id;
        string nomProp;
        address payable porteurProjet;
        uint256 montant;
        string description;
        EtatProposition etat;
        uint32 nbVote;
        uint256 donEcour;
        
    }
    struct PorteurPrjet {
        string nom;
        bool estActive;
    }
     struct Donateur {
         string nom;
         bool estActive;
         bool avote;
         address donateur;
     }
     // Enum l'etat d'elevolution d'un propsition
     enum EtatProposition 
    {
          SelectionEncours,
          Selectionner, 
          Valide,
          Refus
    }
    //event Proposition (uint id,string nomPropo, address porteur,uint256 montant,EtatProposition etat, uint32 nbvote, uint256 donEcore ,uint256 date) ; // evenement sur la Proposition
    event Don(address donateur, uint256, uint256 date); // evenement sur un don 
    // Fonctions uniquement utilisables par le porteursProjets
    modifier estporteur{
       
         require(porteursProjets[msg.sender].estActive == true," vous n ' etes pas inscrit");
         _;
    }
    // Fonctions uniquement utilisables par un L'adminstrateur du contract
    modifier onlyAdmin(){
        require(Admin == msg.sender,"il faut être adminstrateur");
        _;
    }
    
    modifier estDonateur {
        require(donateurs[msg.sender].estActive,"vous n'ête pas donateurs");
        _;
    }
     address public Admin;
      // Liste des ID des  differentes propostion dynamique des propriétés
    uint256[] private listProposition;
    
     // Liste des proteurProjet indexée par son address
     mapping(address=> PorteurPrjet) public porteursProjets;
     
   // Liste des proposition indexée par une valeur numérique
     mapping(uint256 => Proposition) public propositions;
     
      // Liste des donateurs indexée par son address
     mapping(address=> Donateur) public donateurs;
     
     uint256[] private listeSelectionner;
     // liste des ID des differentes propositions selectionner par l 'adminstrateur qui seront emis par les donateurs'
     
    constructor() public{
        Admin = msg.sender;
    }
    
    /**
     * Elle permet au porteur de Projet de s'inscrire 
     * Pour pouvoir ajouter leurs projet pouvoir etre selectionner *
    */
    
    function inscritPorteurProjet(string memory _nom)external{
       require(porteursProjets[msg.sender].estActive == false,"Vous êtes dejat inscrit");
       porteursProjets[msg.sender] = PorteurPrjet(_nom, true);
    }
    
    /**
     * Elle permet au porteur de projet d'ajouter leurs propostion dans la liste
     *  des propostion qui vont être selectionner par l'adminstrateur*
    */
    function ajouterPropositon(uint256 _id, string memory _nomPro, uint256 _montant, string memory _description)external{
     require(propositions[_id].id != _id, "cette proposition existe dejat");
     require(porteursProjets[msg.sender].estActive == true," vous n'etes pas inscrit");
        propositions[_id] = Proposition(_id, _nomPro, msg.sender,_montant,_description, EtatProposition.SelectionEncours,0,0);
        listProposition.push(_id);
       emit Proposition ( _id,_nomPro,msg.sender, _montant,EtatProposition.SelectionEncours,0,0,now) ; // evenement sur la Proposition
        
    }
    /*
     *  elle permet - a l'adminstrateur de selectionner 
       le  propositions qui vont etre vote par les porteursProjets
     *
    **/
    function propositionAselectionner(uint256 _id) external 
    onlyAdmin
    {
        require(propositions[_id].id == _id," cette proposition n'existe pas !");
        //require(listeSelectionner.length< 4, "nombre de selection est atteint");
        require(propositions[_id].etat == EtatProposition.SelectionEncours,"selection doit être en cours");
        require(!propositionExist(_id),"elle est dejat selectionner");
        Proposition storage p = propositions[_id];
        p.etat = EtatProposition.Selectionner;
        listeSelectionner.push(_id);
    }
    /**
     *  cette fonction permet de retourner 
     * une Proposition Selectionner dans
     * le tableau des propositions Selectionner
    */
    function propositionSelectionIndex( uint256 _index) public view returns(Proposition memory) {
        require(_index < listeSelectionner.length,"index n'existe pas ");
        uint256 id = listeSelectionner[_index];
        return propositions[id];
    }
    /*
     *   une function private qui permet de verifier existance d'une Proposition Sectionner*
    **/
    function propositionExist(uint256 _id) internal view returns (bool) {
       for(uint256 i; i< listeSelectionner.length; i++){
          if(propositionSelectionIndex(i).id == _id){
              return true;
          }
       }
     
    }
    /*
     * Elle retourne une Proposition ajouter par le porteursProjets*
    */
    function propositionIndex(uint256 _index) external view returns(Proposition memory){
        require(_index< listProposition.length,"index n'existe pas ");
        uint256 id = listProposition[_index];
        return propositions[id];
        
    }
    /*
     * liste des differentes propositions*
    **/
    function totalProposition() external view returns (uint256) {
        return listProposition.length;
    }
    
    /*
     * total des propositions selectionner pour la vote*
    */
    function totalPropsitionSelectione() external view returns(uint256){
        return listeSelectionner.length;
    }
    /**
     * inscritDonnateur pour voter sur la propositonns a financer*
    *
    */
    function inscritDonnateur(string memory _nom) external {
        donateurs[msg.sender] = Donateur(_nom, true, false, msg.sender);
    }

    /**
     *  permet aux Donateur de voter sur leur propositions*
    */
     
     function voterProposition(uint256 _id) external{
        require(propositions[_id].etat == EtatProposition.Selectionner,"cette propositions n'est pas été Selectionner");
       // require(closeVote()==false,"les votes sont closes");
        Donateur storage Undonateur = donateurs[msg.sender];
        require (Undonateur.donateur == msg.sender, " vous n'avez droit de voter");
        require(!Undonateur.avote, "vous avez votez dejat");
        require(propositionExist(_id),"cette proposition n'existe pas ");
        for(uint256 i; i< listeSelectionner.length; i++){
            if(propositionSelectionIndex(i).id == _id){
               Proposition storage p = propositions[_id];
               p.nbVote= p.nbVote.add(1);
               Undonateur.avote = true; 
            }
        }

    }
    
    /*
     * elle me renvoie dans le tableau de listeSelectionner  index qui a eu plus de vote *
     * 
    **/
    function valideIndex() private view returns(uint256 ) {
     uint256 nvote = 0;
     uint256 indexValid = 0;
     for(uint256 i; i< listeSelectionner.length; i++)
     {
         if(propositionSelectionIndex(i).nbVote > nvote){
             nvote = propositionSelectionIndex(i).nbVote;
             indexValid = i;
         }
     }

     return indexValid;
    }
    
    /*
     *  Une fonction pour arreter les votes *
    */
    function closeVote() external onlyAdmin returns (bool) {
      uint256 index = valideIndex(); // index de la Proposition qui a eu plus de vote
      uint256 id = listeSelectionner[index]; // on recupere son id
      Proposition storage p = propositions[id];
      require(p.etat== EtatProposition.Selectionner,"elle doit etre en etat Selectionner");
      p.etat = EtatProposition.Valide; // on modifier son etat qui passe à valider
       return true;
        
    }
    /**
    * total des propositionValide
    */
    function propositionGagnante() external view onlyAdmin   returns(Proposition memory p)
    {
        uint256 i = valideIndex(); // indice du tableau
        p = propositionSelectionIndex(i);
    }
    
    /*
     * fair un don sur la proposition gagnante *
    **/
    function fairDon( uint256 _id) 
    external 
    estDonateur
    payable 
    {
        Proposition storage p=  propositions[_id];
        require(p.etat == EtatProposition.Valide,"proposition doit etre valide");
        require(msg.value > 0,"le don doit être supérieur à zero");
        // p.porteurProjet.transfer(msg.value);
        transfer(p.porteurProjet,msg.value)
         //p.donEcour += msg.value;
        p.donEcour = donEcour.add(msg.value);
        emit Don(msg.sender,msg.value, now);
    }
    
} 