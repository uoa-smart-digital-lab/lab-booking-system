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
import Login from './Login';
import { Card, Header, Form, Icon } from 'semantic-ui-react'
import {
  ApolloProvider,
  useQuery,
  useMutation
} from "@apollo/client";



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
    return returnValue;
};
const removeQueryStringVal = (key) => {
    let query = getQuery();
    query.delete(key);
    let queryString = "";
    let firstQuery = true;
    for (let queryKey of query.keys()) {
        queryString += (firstQuery?"/?":"&") + queryKey + "=" + query.get(queryKey);
        firstQuery = false;
    }
    let link = window.location.protocol + "//" + window.location.hostname + ":" + window.location.port + queryString;
    window.location = link;
}
// ----------------------------------------------------------------------------------------------------



// ----------------------------------------------------------------------------------------------------
// Clear the parameters from the url
// ----------------------------------------------------------------------------------------------------
function clearParameters() {
    window.history.pushState({}, document.title, window.location.pathname);
}
// ----------------------------------------------------------------------------------------------------



// ----------------------------------------------------------------------------------------------------
// Get a list of all the items in the database
// ----------------------------------------------------------------------------------------------------
function FindItems({dologin, dologout, sessionid}) {
    const { loading, error, data } = useQuery(GraphQL.ITEMALL, {
        context : { headers : { sessionid : sessionid } },
        fetchPolicy: 'network-only'
    });

    if (loading) return (<Loading />);
    if (error) return (<Error message={error.message} />);
    
    return (
        <AllItems data={data} dologin={dologin} dologout={dologout} sessionid={sessionid}/>
    );
}
// ----------------------------------------------------------------------------------------------------



// ----------------------------------------------------------------------------------------------------
// Get the Bookings of a specific item
// ----------------------------------------------------------------------------------------------------
function GetBookings ({dologin, dologout, item_name, sessionid}) {
    const { loading, error, data } = useQuery(GraphQL.BOOKINGALL, {
        variables: {name: item_name},
        context : { headers : { sessionid : sessionid } },
        fetchPolicy: 'network-only'
    });

    if (loading) return (<Loading />);
    if (error) return (<Error message={error.message} />);

    return (
        <Bookings name={data.itemGet.name} url={data.itemGet.url} image={data.itemGet.image} bookable={data.itemGet.bookable} access={data.itemGet.access} details={data.itemGet.details} bookings={data.itemGet.bookings} inductions={data.itemGet.inductions} dologin={dologin} dologout={dologout} sessionid={sessionid}/>
    );
}   
// ----------------------------------------------------------------------------------------------------



// ----------------------------------------------------------------------------------------------------
// Display a QR code for a specific item
// ----------------------------------------------------------------------------------------------------
function ItemQRCode ({name, sessionid}) {
    const { loading, error, data } = useQuery(GraphQL.ITEMGET, {
        variables: {name: name},
        context : { headers : { sessionid : sessionid } },
        fetchPolicy: 'network-only'
    });
    
    if (loading) return (<Loading />);
    if (error) return (<Error message={error.message} />);

    return (
        <ItemQR name={data.itemGet.name} url={data.itemGet.url} image={data.itemGet.image}/>
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
    handleChange = (e, { name, value }) => { this.setState({ [name]: value }); }
    
    constructor(props) {
        super (props);
        this.state = { loggingin: false, loading: false, error: false, data: {}, upi: '', sessionid: '', errorMessage: ''};
    }


    render ()
    {
        // Get any parameters sent in
        const item_name = getQueryStringVal("item");
        const book = getQueryStringVal("book");
        const qrcode = getQueryStringVal("qrcode");
        const sessionid = getQueryStringVal("sessionid");
        if (sessionid) {
            this.state.sessionid = sessionid; // Set the value without triggering a reload of the page.
        }

        // clearParameters();

        // Set up the return html
        let return_value;

        // Check each of the parameters and generate the appropriate html
        // A specific item name is given, so show occupancy in that item
        if (item_name) { return_value = ( <GetBookings item_name={item_name} sessionid={this.state.sessionid} dologout={() => {removeQueryStringVal("sessionid"); this.setState({"sessionid": ''}); }} dologin={() => {this.setState({"loggingin": true}); }}/> ) }
        // Booking in or out - this is reached by booking the QR Code
        else if (book) { return_value = ( <Bookinorout item_name={book} /> ); }
        // Generate a QR code for use with booking in or out.
        else if (qrcode) { return_value = ( <ItemQRCode name={qrcode}/> ); }
        else {
            if (this.state.loggingin)
            {
                return_value = (<Login errorMessage={this.state.errorMessage} error={() => {this.setState({"errorMessage": "Error logging in"});}} loggedin={(result) => {this.setState({"sessionid": result.sessionid}); this.setState({"loggingin": false});}}/>);
            }
            else
            {
                return_value = ( <FindItems sessionid={this.state.sessionid} dologout={() => {removeQueryStringVal("sessionid"); this.setState({"sessionid": ''}); }} dologin={() => {this.setState({"loggingin": true}); }}/> );
            }
        }

        return ( <ApolloProvider client={GraphQL.client}> {return_value} </ApolloProvider> );
    }
}

export default App;
// ----------------------------------------------------------------------------------------------------
