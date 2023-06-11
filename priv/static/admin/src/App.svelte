<script lang="ts">
    import Table_Persons from "./lib/Table_Persons.svelte";
    import GraphQL_Table from "./lib/GraphQL_Table.svelte";
    import { PersonDetails, GraphQL, Person} from "./lib/Graphql.svelte";
    import type { Persons } from "./lib/Graphql.svelte";
    import { Usertype, Session, Item } from "./lib/Graphql.svelte";

    // let details: PersonDetails = new PersonDetails("123456789", "here@there");

    // let persons: Persons = new Persons();
    // persons.push(new Person("rdav031", "Roy Davies", "", Usertype.ADMIN, details, 0, null, null));
    // persons.push(new Person("fdag1234", "Fred Dagg", "", Usertype.USER, details, 0, null, null));

    GraphQL.start();

    let session: Session = new Session();
    session.login("rdav031", "12345")
    .then(() => {
        // Login successful
        console.log("Logged in :", session);


    })
    .catch((error) => {
        // Login failed, handle error
    });

    Item.ItemAll()

</script>

<main>
    <!-- <GraphQL_Table definition="Person" data={persons}/> -->
</main>

<style>

</style>
