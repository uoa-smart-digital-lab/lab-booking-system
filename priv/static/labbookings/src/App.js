import React, { Component } from 'react';
import 'semantic-ui-css/semantic.min.css';
import './App.css';
import BookedIn from './BookedIn'
import Bookings from './Bookings'
import AllItems from './AllItems'
import GraphQL from './graphql';
import Error from './Error';
import ItemQR from './ItemQR';
import Loading from './Loading';
import { Card, Header, Form, Icon } from 'semantic-ui-react'
import {
  ApolloClient,
  InMemoryCache,
  ApolloProvider,
  useQuery,
  useMutation,
  gql
} from "@apollo/client";



// ----------------------------------------------------------------------------------------------------
// The GraphQL Parameters
// ----------------------------------------------------------------------------------------------------
const client = new ApolloClient({
    uri: '/api',
    cache: new InMemoryCache()
});
// ----------------------------------------------------------------------------------------------------



// ----------------------------------------------------------------------------------------------------
// Get values in the query
// ----------------------------------------------------------------------------------------------------
const getQuery = () => {
    if (typeof window !== 'undefined') {
      return new URLSearchParams(window.location.search);
    }
    return new URLSearchParams();
};
const getQueryStringVal = (key) => {
    let query = getQuery();
    let returnValue = query.get(key);
    window.history.pushState({}, document.title, window.location.pathname);
    return returnValue;
};
// ----------------------------------------------------------------------------------------------------



// ----------------------------------------------------------------------------------------------------
// Get a list of all the items in the database
// ----------------------------------------------------------------------------------------------------
function FindItems() {
    const { loading, error, data } = useQuery(GraphQL.ITEMALL);

    if (loading) return (<Loading />);
    if (error) return (<Error message={error.message} />);

    return (
            <AllItems data={data} />
        );
}
// ----------------------------------------------------------------------------------------------------



// ----------------------------------------------------------------------------------------------------
// Get the Bookings of a specific item
// ----------------------------------------------------------------------------------------------------
function GetBookings ({item_name}) {
    const { loading, error, data } = useQuery(GraphQL.BOOKINGALL, {
        variables: {itemName: item_name}
    });

    if (loading) return (<Loading />);
    if (error) return (<Error message={error.message} />);

    return (
        <Bookings itemName={data.bookingAll.item.name} bookings={data.bookingAll.bookings}/>
    );
}   
// ----------------------------------------------------------------------------------------------------



// ----------------------------------------------------------------------------------------------------
// Display a QR code for a specific item
// ----------------------------------------------------------------------------------------------------
function ItemQRCode ({name}) {
    const { loading, error, data } = useQuery(GraphQL.ITEMGET, {
        variables: {name: name}
    });  
    
    if (loading) return (<Loading />);
    if (error) return (<Error message={error.message} />);

    return (
        <ItemQR id={data.itemGet.id} name={data.itemGet.name} url={data.itemGet.url}/>
    );
}
// ----------------------------------------------------------------------------------------------------



// ----------------------------------------------------------------------------------------------------
// Do the Booking In or Out.  Note, this has to be here and not in another file due to the useMutation
// and something to do with different version of React.  Also, has to be a function and not a class.
// ----------------------------------------------------------------------------------------------------
var entered_upi = "";
function Bookinorout({item_name}) {
    const [bookInOrOut, { data, loading, error }] = useMutation(GraphQL.SCANINOROUT);

    let handleChange = (e, { name, value }) => { entered_upi = value; }
    let handleSubmit = () => {
        bookInOrOut({variables: { upi: entered_upi, itemName: item_name}})
    }

    if (loading) return (<Loading />);
    if (error) return (<Error message={error.message} />);

    if (data)
    {
        return (<BookedIn occupants={data.bookInOrOut.occupants} upi={entered_upi} itemName={item_name}/>);
    }
    else
    {
        return (
            <div>
                <Header centered as="h3" color='blue' block>
                    Book in or out of {item_name}
                </Header>
                <Card.Group centered>
                    <Card invert color="blue" icon>
                        <Card.Content>
                            <Icon color="blue" name='id badge' size='massive'/>
                        </Card.Content>
                        <Form onSubmit={handleSubmit}>
                            <Card.Content>
                                <Form.Input
                                    size="big" key="big" 
                                    fluid
                                    focus
                                    placeholder='UPI...'
                                    name='upi'
                                    // value={entered_upi}
                                    onChange={handleChange}
                                />
                            </Card.Content>
                            <Card.Content>
                                <Form.Button size="big" key="big" primary fluid content='Book In or Out' />
                            </Card.Content>
                        </Form>
                    </Card>
                </Card.Group>
            </div>
        ) 
    }
}
// ----------------------------------------------------------------------------------------------------



// ----------------------------------------------------------------------------------------------------
// The main App
// ----------------------------------------------------------------------------------------------------
class App extends Component
{
    
    constructor(props) {
        super (props);
        this.state = { loading: false, error: false, data: {}, upi: '' };
    }


    render ()
    {
        // Get any parameters sent in
        const item_name = getQueryStringVal("item");
        const book = getQueryStringVal("book");
        const qrcode = getQueryStringVal("qrcode");

        // Set up the return html
        let return_value;

        // Check each of the parameters and generate the appropriate html
        // A specific item name is given, so show occupancy in that item
        if (item_name) { return_value = ( <GetBookings item_name={item_name}/> ) }
        // Booking in or out - this is reached by booking the QR Code
        else if (book) { return_value = ( <Bookinorout item_name={book} /> ); }
        // Generate a QR code for use with booking in or out.
        else if (qrcode) { return_value = ( <ItemQRCode name={qrcode}/> ); }
        else { return_value = ( <FindItems /> ); }

        return ( <ApolloProvider client={client}> {return_value} </ApolloProvider> );

    }
}

export default App;
// ----------------------------------------------------------------------------------------------------
