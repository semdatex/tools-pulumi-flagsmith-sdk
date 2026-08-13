import * as pulumi from "@pulumi/pulumi";
export declare class Environment extends pulumi.CustomResource {
    /**
     * Get an existing Environment resource's state with the given name, ID, and optional extra
     * properties used to qualify the lookup.
     *
     * @param name The _unique_ name of the resulting resource.
     * @param id The _unique_ provider ID of the resource to lookup.
     * @param state Any extra arguments used during the lookup.
     * @param opts Optional settings to control the behavior of the CustomResource.
     */
    static get(name: string, id: pulumi.Input<pulumi.ID>, state?: EnvironmentState, opts?: pulumi.CustomResourceOptions): Environment;
    /**
     * Returns true if the given object is an instance of Environment.  This is designed to work even
     * when multiple copies of the Pulumi SDK have been loaded into the same process.
     */
    static isInstance(obj: any): obj is Environment;
    /**
     * Allows clients using the client API key to set traits.
     */
    readonly allowClientTraits: pulumi.Output<boolean>;
    /**
     * Client side API Key
     */
    readonly apiKey: pulumi.Output<string>;
    /**
     * hex code for the UI banner colour
     */
    readonly bannerColour: pulumi.Output<string | undefined>;
    /**
     * Banner text to display in the UI
     */
    readonly bannerText: pulumi.Output<string | undefined>;
    /**
     * Description of the environment
     */
    readonly description: pulumi.Output<string | undefined>;
    /**
     * ID of the environment
     */
    readonly environmentId: pulumi.Output<number>;
    /**
     * If true will exclude flags from SDK which are disabled
     */
    readonly hideDisabledFlags: pulumi.Output<boolean>;
    /**
     * If true, will hide sensitive data(e.g: traits, description etc) from the SDK endpoints
     */
    readonly hideSensitiveData: pulumi.Output<boolean>;
    /**
     * Minimum number of approvals required for a change request
     */
    readonly minimumChangeRequestApprovals: pulumi.Output<number>;
    /**
     * Name of the environment
     */
    readonly name: pulumi.Output<string>;
    /**
     * ID of the project
     */
    readonly projectId: pulumi.Output<number>;
    /**
     * Enable this to have consistent multivariate and percentage split evaluations across all SDKs (in local and server side mode)
     */
    readonly useIdentityCompositeKeyForHashing: pulumi.Output<boolean>;
    /**
     * UUID of the environment
     */
    readonly uuid: pulumi.Output<string>;
    /**
     * Create a Environment resource with the given unique name, arguments, and options.
     *
     * @param name The _unique_ name of the resource.
     * @param args The arguments to use to populate this resource's properties.
     * @param opts A bag of options that control this resource's behavior.
     */
    constructor(name: string, args: EnvironmentArgs, opts?: pulumi.CustomResourceOptions);
}
/**
 * Input properties used for looking up and filtering Environment resources.
 */
export interface EnvironmentState {
    /**
     * Allows clients using the client API key to set traits.
     */
    allowClientTraits?: pulumi.Input<boolean | undefined>;
    /**
     * Client side API Key
     */
    apiKey?: pulumi.Input<string | undefined>;
    /**
     * hex code for the UI banner colour
     */
    bannerColour?: pulumi.Input<string | undefined>;
    /**
     * Banner text to display in the UI
     */
    bannerText?: pulumi.Input<string | undefined>;
    /**
     * Description of the environment
     */
    description?: pulumi.Input<string | undefined>;
    /**
     * ID of the environment
     */
    environmentId?: pulumi.Input<number | undefined>;
    /**
     * If true will exclude flags from SDK which are disabled
     */
    hideDisabledFlags?: pulumi.Input<boolean | undefined>;
    /**
     * If true, will hide sensitive data(e.g: traits, description etc) from the SDK endpoints
     */
    hideSensitiveData?: pulumi.Input<boolean | undefined>;
    /**
     * Minimum number of approvals required for a change request
     */
    minimumChangeRequestApprovals?: pulumi.Input<number | undefined>;
    /**
     * Name of the environment
     */
    name?: pulumi.Input<string | undefined>;
    /**
     * ID of the project
     */
    projectId?: pulumi.Input<number | undefined>;
    /**
     * Enable this to have consistent multivariate and percentage split evaluations across all SDKs (in local and server side mode)
     */
    useIdentityCompositeKeyForHashing?: pulumi.Input<boolean | undefined>;
    /**
     * UUID of the environment
     */
    uuid?: pulumi.Input<string | undefined>;
}
/**
 * The set of arguments for constructing a Environment resource.
 */
export interface EnvironmentArgs {
    /**
     * Allows clients using the client API key to set traits.
     */
    allowClientTraits?: pulumi.Input<boolean | undefined>;
    /**
     * hex code for the UI banner colour
     */
    bannerColour?: pulumi.Input<string | undefined>;
    /**
     * Banner text to display in the UI
     */
    bannerText?: pulumi.Input<string | undefined>;
    /**
     * Description of the environment
     */
    description?: pulumi.Input<string | undefined>;
    /**
     * If true will exclude flags from SDK which are disabled
     */
    hideDisabledFlags?: pulumi.Input<boolean | undefined>;
    /**
     * If true, will hide sensitive data(e.g: traits, description etc) from the SDK endpoints
     */
    hideSensitiveData?: pulumi.Input<boolean | undefined>;
    /**
     * Minimum number of approvals required for a change request
     */
    minimumChangeRequestApprovals?: pulumi.Input<number | undefined>;
    /**
     * Name of the environment
     */
    name?: pulumi.Input<string | undefined>;
    /**
     * ID of the project
     */
    projectId: pulumi.Input<number>;
    /**
     * Enable this to have consistent multivariate and percentage split evaluations across all SDKs (in local and server side mode)
     */
    useIdentityCompositeKeyForHashing?: pulumi.Input<boolean | undefined>;
}
//# sourceMappingURL=environment.d.ts.map