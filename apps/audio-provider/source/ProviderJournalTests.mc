using Toybox.Application;
using Toybox.Test;
(:test)
function providerJournalRetainsUnacknowledgedEventsAndRewinds(logger) {
    Application.Storage.setValue(ProviderControl.PAIR,"test-profile");
    Application.Storage.setValue(ProviderJournal.NEXT,0);
    Application.Storage.setValue(ProviderJournal.HEAD,1);
    for(var i=0;i<110;i++){ProviderJournal.record("test-book",110-i,120,"pause",false);}
    var first=ProviderJournal.events();
    Test.assert(first.size()==5);
    Test.assert(first[0]["pos"]==110);
    Test.assert(!ProviderJournal.acknowledge(["2"]));
    Test.assert(ProviderJournal.acknowledge(["1","2","3","4","5"]));
    Test.assert(ProviderJournal.events()[0]["pos"]==105);
    Application.Storage.setValue(ProviderJournal.HEAD,106);
    Test.assert(ProviderJournal.events()[4]["pos"]==1);
    for(var n=6;n<=110;n++){Application.Storage.deleteValue(ProviderJournal.key(n));}
    Application.Storage.deleteValue(ProviderJournal.NEXT);
    Application.Storage.deleteValue(ProviderJournal.HEAD);
    Application.Storage.deleteValue(ProviderControl.PAIR);
    return true;
}
