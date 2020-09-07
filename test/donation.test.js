
const {BN,expectEvent, expectRevert,constants} = require("@openzeppelin/test-helpers");
const Donation = artifacts.require("Donation");
contract("Donation",(accounts)=>{
    const owner = accounts[0];
    const porteurProjet1 = accounts[1];
    const porteurProjet2 = accounts[2];
    const porteurProjet3 = accounts[3];
    const donateur1 = accounts[4];
    const donateur2 = accounts[5];
    const donateur3 = accounts[6];
    // ici initialisation d'une propsition
    const nomProposition = "Coronavirus";
    const id = new BN("30");
    const mont = new BN("100");
    // const nbreVote = new BN("0");
    // const donEncour = new BN("0");

    const desc = "Description sur la proposition";


    const EtatProposition 
    {
          SelectionEncours : "0",
          Selectionner : "1", 
          Valide : "2",
          Refus:"3";
    };

    it("should deploy the smart contract correctly",async()=>{
         this.Donation = await Donation.new({from:owner});
         console.log(donation.address)
         assert(donation.address!=="" && donation.address !== undefined)

    })
    it(" inscription PorteurProjet et ajout Proposition", async()=>{
    
         await this.Donation.inscritPorteurProjet(porteurProjet1,{from:porteurProjet1});
         const proposition= await donation.ajouterPropositon(id,nomProposition,mont,desc)
         expectEvent(proposition,"Proposition",{porteurProjet1:{from:porteurProjet1}})

    } );
    it("ajout d'un donateur",async()=>{
        await this.Donation.inscritDonnateur(donateur1, {from:donateur1})

    });
    it("Selection d'un proposition", async () => {
      await this.Donation. propositionAselectionner(id,{from:owner})
      expect(await this.Donation.listProposition()).to.have.length(1);
    })
    it(" Vote une Proposition Par une donateur", async () => {
      await this.Donation.voterProposition(id,{from:donateur1})
      assert(await this.Donation.listProposition(0).nbreVote >0);

    })

    it("fairDon", async () => {
         const don = await expectRevert(this.Donation.fairDon(id,{from:donateur1, value: new BN("100")}));
        expectEvent(don, "Transfer",{donateur1: {from:donateur1}})
    })
  
})