// Copyright (c) 2025, WSO2 LLC. (http://www.wso2.org).
//
// WSO2 LLC. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

import ballerina/http;
import ballerina/jwt;
import ballerina/websubhub;
import ballerinax/kafka;

# Represents a snapshot of the WebSubHub's state, containing all topics and subscriptions.
public type SystemStateSnapshot record {|
    # An array of current topic registrations in the hub
    websubhub:TopicRegistration[] topics;
    # An array of all verified subscriptions in the hub
    websubhub:VerifiedSubscription[] subscriptions;
|};

public type StaleSubscription record {|
    *websubhub:VerifiedSubscription;
    string status = "stale";
|};

public type SubscriptionDetails record {|
    string topic;
    string subscriberId;
|};

public type InvalidSubscriptionError distinct error<SubscriptionDetails>;

# Defines the configuration for the WebSubHub server endpoint.
public type ServerConfig record {|
    # The port on which the WebSubHub service will listen
    int port;
    # A unique identifier for this WebSubHub server instance
    string id;
    # Authentication configurations for securing the hub's endpoints
    JwtValidatorConfig auth?;
    # SSL/TLS configurations for the service endpoint
    http:ListenerSecureSocket secureSocket?;
|};

# Represents JWT validator configurations for JWT-based authentication.
public type JwtValidatorConfig record {|
    # The key used to extract the 'scope' claim from the JWT payload
    string scopeKey;
    # The expected issuer of the JWT, corresponding to the `iss` claim
    string issuer;
    # The expected audience for the JWT, corresponding to the `aud` claim
    string|string[] audience;
    # JWKS-based signature validation configurations
    JwksConfig signature?;
|};

# Represents the JWKS (JSON Web Key Set) configurations for JWT signature validation.
public type JwksConfig record {|
    # The URL of the JWKS endpoint
    string url;
    # SSL/TLS configurations for the JWKS client
    jwt:SecureSocket secureSocket?;
|};

# Defines configurations for retrieving and maintaining the server's state.
public type ServerStateConfig record {|
    # Configurations for retrieving the initial state snapshot from a consolidator service.
    record {|
        # The HTTP endpoint URL of the consolidator to get the state snapshot
        string url;
        # Client configurations for the HTTP call to the consolidator
        HttpClientConfig config?;
    |} snapshot;
    # Configurations for consuming state update events from a Kafka topic.
    record {|
        # The Kafka topic that stores WebSub events for this server
        string topic;
        # The consumer group ID used by the Kafka consumer for state update events
        string consumerGroup;
    |} events;
|};

# Defines the complete set of Kafka configurations required for the application.
public type KafkaConfig record {|
    # Kafka connection configurations
    KafkaConnectionConfig connection;
    # Kafka consumer-specific configurations
    KafkaConsumerConfig consumer;
|};

# Defines the configurations for establishing a connection to a Kafka cluster.
public type KafkaConnectionConfig record {|
    # A list of remote server endpoints for the Kafka brokers (e.g., "localhost:9092")
    string|string[] bootstrapServers;
    # SSL/TLS configurations for the Kafka connection
    kafka:SecureSocket secureSocket?;
    # Authentication-related configurations for the Kafka connection
    kafka:AuthenticationConfiguration auth?;
    # The security protocol to use for the broker connection (e.g., PLAINTEXT, SSL)
    kafka:SecurityProtocol securityProtocol = kafka:PROTOCOL_PLAINTEXT;
|};

# Defines configurations for the Kafka consumer.
public type KafkaConsumerConfig record {|
    # The maximum number of records to return in a single call to `poll` function
    int maxPollRecords;
    # The polling interval in seconds for fetching new records
    decimal pollingInterval = 10;
    # The timeout duration (in seconds) for a graceful shutdown of the consumer
    decimal gracefulClosePeriod = 5;
|};

# Defines configurations for an HTTP client.
public type HttpClientConfig record {|
    # The maximum time (in seconds) to wait for a response before the request times out
    decimal timeout = 60;
    # Automatic retry settings for failed HTTP requests
    http:RetryConfig 'retry?;
    # SSL/TLS configurations for the HTTP client
    http:ClientSecureSocket secureSocket?;
|};
