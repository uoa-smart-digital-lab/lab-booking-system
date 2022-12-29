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
import { Header, Form, Modal, Divider, Grid, Button } from 'semantic-ui-react'
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
// function clearParameters() {
//     window.history.pushState({}, document.title, window.location.pathname);
// }
// ----------------------------------------------------------------------------------------------------



// ----------------------------------------------------------------------------------------------------
// Get a list of all the items in the database
// ----------------------------------------------------------------------------------------------------
function FindItems({dologin, dologout, sessionid, upi}) {
    const { loading, error, data } = useQuery(GraphQL.ITEMALL, {
        context : { headers : { sessionid : sessionid } },
        fetchPolicy: 'network-only'
    });

    if (loading) return (<Loading />);
    if (error) return (<Error message={error.message} />);
    
    return (
        <AllItems data={data} dologin={dologin} dologout={dologout} upi={upi} sessionid={sessionid}/>
    );
}
// ----------------------------------------------------------------------------------------------------



// ----------------------------------------------------------------------------------------------------
// Get the Bookings of a specific item
// ----------------------------------------------------------------------------------------------------
function GetBookings ({dologin, dologout, dobooking, itemname, sessionid, upi}) {
    const { loading, error, data } = useQuery(GraphQL.ITEMGET, {
        variables: {name: itemname},
        context : { headers : { sessionid : sessionid } },
        fetchPolicy: 'network-only'
    });

    if (loading) return (<Loading />);
    if (error) return (<Error message={error.message} />);

    return (
            <Bookings 
                name={data.itemGet.name} 
                url={data.itemGet.url} 
                image={data.itemGet.image} 
                bookable={data.itemGet.bookable} 
                access={data.itemGet.access} 
                details={data.itemGet.details} 
                bookings={data.itemGet.bookings} 
                inductions={data.itemGet.inductions} 
                dologin={dologin} 
                dologout={dologout} 
                dobooking={dobooking} 
                sessionid={sessionid} 
                upi={upi}/>
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
// Book the Item.  Note, this has to be here and not in another file due to the useMutation
// and something to do with different version of React.  Also, has to be a function and not a class.
// ----------------------------------------------------------------------------------------------------
var entered_upi = "";
function ConfirmBooking({itemname, starttime, endtime, upi}) {
    const [itemBook, { data, loading, error }] = useMutation(GraphQL.ITEMBOOK);

	let handleChange = (e, { name, value }) => { [name] = value; };
    let handleSubmit = () => {
        const variables = { upi: upi, itemname: itemname, starttime: starttime, endtime: endtime, details:"{}"};
		itemBook({variables: variables})
    }

    if (loading) return (<Loading />);
    if (error) return (<Error message={error.message} />);

    console.log("HERE");
    if (data)
    {
        console.log("DATA");
        console.log(data);
        return (<BookedIn occupants={data.bookInOrOut.occupants} upi={entered_upi} itemName={itemname}/>);
    }
    else
    {
        console.log("MODAL");
        return (
            <Modal open={true} size='tiny' >
                <Modal.Content>
                <Header as='h4' textAlign='center'>
                    <span>Make Booking</span><br/><span>Set Start and End Times.</span><br/>
                </Header>
                <Divider />
                <Grid columns='one'>
                    <Grid.Row>
                    <Grid.Column>
                        <Form>
                        <Form.Field>
                            <Form.Input placeholder="Start Time" name="starttime" type="text" value={starttime} onChange={handleChange}/>
                        </Form.Field>
                        <Form.Field>
                            <Form.Input placeholder="End Time" name="endtime" type="text" value={endtime} onChange={handleChange}/>
                        </Form.Field>
                        </Form>
                    </Grid.Column>
                    </Grid.Row>
                </Grid>
                </Modal.Content>
                <Modal.Actions style={{ paddingLeft: '1.5em', paddingRight: '1.5em' }}>
                <Grid columns='one'>
                    <Grid.Row>
                    <Grid.Column>
                        <Button fluid basic color='green' onClick={handleSubmit}>Make Booking</Button>
                    </Grid.Column>
                    </Grid.Row>
                </Grid>
                </Modal.Actions>
            </Modal>
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
        this.state = { 
            loggingin: false,
            confirmingbooking: false,
            loading: false, 
            error: false, 
            data: {},
            itemname: '',
            upi: '', 
            sessionid: '', 
            errorMessage: '',
            starttime: '',
            endtime: ''
        };
    }


    render ()
    {
        // Get any parameters sent in
        const itemname = getQueryStringVal("item");
        // const book = getQueryStringVal("book");
        const qrcode = getQueryStringVal("qrcode");
        const sessionid = getQueryStringVal("sessionid");
        if (sessionid) {
            this.state.sessionid = sessionid; // Set the value without triggering a reload of the page.
        }
        const upi = getQueryStringVal("upi");
        if (upi) {
            this.state.upi = upi; // Set the value without triggering a reload of the page.
        }

        // clearParameters();

        // Set up the return html
        let return_value;

        if (this.state.confirmingbooking)
        {
            console.log("CONFIRMING");
            return_value = (
                <ConfirmBooking     itemname = {this.state.itemname}
                                    starttime = {this.state.starttime}
                                    endtime = {this.state.endtime}
                                    upi = {this.state.upi}
                />
            )
        }
        if (this.state.loggingin)
        {
            return_value = (
                <Login  errorMessage={this.state.errorMessage} 
                        error={() => {
                            this.setState({"errorMessage": "Error logging in"});
                        }} 
                        loggedin={(result) => {
                            this.setState({"sessionid": result.sessionid}); 
                            this.setState({"upi": result.upi}); 
                            this.setState({"loggingin": false});
                        }}
                />
            );
        }
        else
        {
            // Check each of the parameters and generate the appropriate html
            // A specific item name is given, so show occupancy in that item
            if (itemname) { 
                return_value = ( 
                    <GetBookings    itemname={itemname} 
                                    upi={this.state.upi} 
                                    sessionid={this.state.sessionid} 
                                    dologout={() => {
                                        removeQueryStringVal("upi"); 
                                        removeQueryStringVal("sessionid"); 
                                        this.setState({"sessionid": ''}); 
                                        this.setState({"upi": ''});
                                    }} 
                                    dologin={() => {
                                        this.setState({"loggingin": true}); 
                                    }}
                                    dobooking={(starttime, endtime, itemname, upi) => {
                                        this.setState({"starttime": starttime}); 
                                        this.setState({"endtime": endtime}); 
                                        this.setState({"itemname": itemname}); 
                                        this.setState({"upi": upi}); 
                                        this.setState({"confirmingbooking": true})
                                    }}
                    />
                ) 
            }
            // Generate a QR code for use with booking in or out.
            else if (qrcode) { return_value = ( <ItemQRCode name={qrcode}/> ); }
            else {
                return_value = (
                    <FindItems  sessionid={this.state.sessionid} 
                                upi={this.state.upi} 
                                dologout={() => {
                                    removeQueryStringVal("upi"); 
                                    removeQueryStringVal("sessionid"); 
                                    this.setState({"sessionid": ''}); 
                                    this.setState({"upi": ''});
                                }} 
                                dologin={() => {
                                    this.setState({"loggingin": true}); 
                                }}
                    /> 
                );
            }
        }

        return ( <ApolloProvider client={GraphQL.client}> {return_value} </ApolloProvider> );
    }
}

export default App;
// ----------------------------------------------------------------------------------------------------
