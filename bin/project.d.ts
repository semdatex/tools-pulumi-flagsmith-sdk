import * as pulumi from "@pulumi/pulumi";
export declare class Project extends pulumi.CustomResource {
    /**
     * Get an existing Project resource's state with the given name, ID, and optional extra
     * properties used to qualify the lookup.
     *
     * @param name The _unique_ name of the resulting resource.
     * @param id The _unique_ provider ID of the resource to lookup.
     * @param state Any extra arguments used during the lookup.
     * @param opts Optional settings to control the behavior of the CustomResource.
     */
    static get(name: string, id: pulumi.Input<pulumi.ID>, state?: ProjectState, opts?: pulumi.CustomResourceOptions): Project;
    /**
     * Returns true if the given object is an instance of Project.  This is designed to work even
     * when multiple copies of the Pulumi SDK have been loaded into the same process.
     */
    static isInstance(obj: any): obj is Project;
    /**
     * Enable this to trigger a realtime(sse) event whenever the value of a flag changes
     */
    readonly enableRealtimeUpdates: pulumi.Output<boolean>;
    /**
     * If true, feature creation requires at least one owner or group owner.
     */
    readonly enforceFeatureOwners: pulumi.Output<boolean>;
    /**
     * Used for validating feature names
     */
    readonly featureNameRegex: pulumi.Output<string>;
    /**
     * If true will exclude flags from SDK which are disabled
     */
    readonly hideDisabledFlags: pulumi.Output<boolean>;
    /**
     * Name of the project
     */
    readonly name: pulumi.Output<string>;
    /**
     * Used by UI to validate feature names
     */
    readonly onlyAllowLowerCaseFeatureNames: pulumi.Output<boolean>;
    /**
     * ID of the organisation project belongs to
     */
    readonly organisationId: pulumi.Output<number>;
    /**
     * Prevent defaults from being set in all environments when creating a feature.
     */
    readonly preventFlagDefaults: pulumi.Output<boolean>;
    /**
     * ID of the project
     */
    readonly projectId: pulumi.Output<number>;
    /**
     * Number of days without modification in any environment before a flag is considered stale.
     */
    readonly staleFlagsLimitDays: pulumi.Output<number>;
    /**
     * UUID of the project
     */
    readonly uuid: pulumi.Output<string>;
    /**
     * Create a Project resource with the given unique name, arguments, and options.
     *
     * @param name The _unique_ name of the resource.
     * @param args The arguments to use to populate this resource's properties.
     * @param opts A bag of options that control this resource's behavior.
     */
    constructor(name: string, args: ProjectArgs, opts?: pulumi.CustomResourceOptions);
}
/**
 * Input properties used for looking up and filtering Project resources.
 */
export interface ProjectState {
    /**
     * Enable this to trigger a realtime(sse) event whenever the value of a flag changes
     */
    enableRealtimeUpdates?: pulumi.Input<boolean | undefined>;
    /**
     * If true, feature creation requires at least one owner or group owner.
     */
    enforceFeatureOwners?: pulumi.Input<boolean | undefined>;
    /**
     * Used for validating feature names
     */
    featureNameRegex?: pulumi.Input<string | undefined>;
    /**
     * If true will exclude flags from SDK which are disabled
     */
    hideDisabledFlags?: pulumi.Input<boolean | undefined>;
    /**
     * Name of the project
     */
    name?: pulumi.Input<string | undefined>;
    /**
     * Used by UI to validate feature names
     */
    onlyAllowLowerCaseFeatureNames?: pulumi.Input<boolean | undefined>;
    /**
     * ID of the organisation project belongs to
     */
    organisationId?: pulumi.Input<number | undefined>;
    /**
     * Prevent defaults from being set in all environments when creating a feature.
     */
    preventFlagDefaults?: pulumi.Input<boolean | undefined>;
    /**
     * ID of the project
     */
    projectId?: pulumi.Input<number | undefined>;
    /**
     * Number of days without modification in any environment before a flag is considered stale.
     */
    staleFlagsLimitDays?: pulumi.Input<number | undefined>;
    /**
     * UUID of the project
     */
    uuid?: pulumi.Input<string | undefined>;
}
/**
 * The set of arguments for constructing a Project resource.
 */
export interface ProjectArgs {
    /**
     * Enable this to trigger a realtime(sse) event whenever the value of a flag changes
     */
    enableRealtimeUpdates?: pulumi.Input<boolean | undefined>;
    /**
     * If true, feature creation requires at least one owner or group owner.
     */
    enforceFeatureOwners?: pulumi.Input<boolean | undefined>;
    /**
     * Used for validating feature names
     */
    featureNameRegex?: pulumi.Input<string | undefined>;
    /**
     * If true will exclude flags from SDK which are disabled
     */
    hideDisabledFlags?: pulumi.Input<boolean | undefined>;
    /**
     * Name of the project
     */
    name?: pulumi.Input<string | undefined>;
    /**
     * Used by UI to validate feature names
     */
    onlyAllowLowerCaseFeatureNames?: pulumi.Input<boolean | undefined>;
    /**
     * ID of the organisation project belongs to
     */
    organisationId: pulumi.Input<number>;
    /**
     * Prevent defaults from being set in all environments when creating a feature.
     */
    preventFlagDefaults?: pulumi.Input<boolean | undefined>;
    /**
     * Number of days without modification in any environment before a flag is considered stale.
     */
    staleFlagsLimitDays?: pulumi.Input<number | undefined>;
}
//# sourceMappingURL=project.d.ts.map