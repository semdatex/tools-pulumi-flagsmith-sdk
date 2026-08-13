import * as pulumi from "@pulumi/pulumi";
export declare class Feature extends pulumi.CustomResource {
    /**
     * Get an existing Feature resource's state with the given name, ID, and optional extra
     * properties used to qualify the lookup.
     *
     * @param name The _unique_ name of the resulting resource.
     * @param id The _unique_ provider ID of the resource to lookup.
     * @param state Any extra arguments used during the lookup.
     * @param opts Optional settings to control the behavior of the CustomResource.
     */
    static get(name: string, id: pulumi.Input<pulumi.ID>, state?: FeatureState, opts?: pulumi.CustomResourceOptions): Feature;
    /**
     * Returns true if the given object is an instance of Feature.  This is designed to work even
     * when multiple copies of the Pulumi SDK have been loaded into the same process.
     */
    static isInstance(obj: any): obj is Feature;
    /**
     * Determines if the feature is enabled by default. If unspecified, it will default to false
     */
    readonly defaultEnabled: pulumi.Output<boolean>;
    /**
     * Description of the feature
     */
    readonly description: pulumi.Output<string | undefined>;
    /**
     * ID of the feature
     */
    readonly featureId: pulumi.Output<number>;
    /**
     * Name of the feature
     */
    readonly featureName: pulumi.Output<string>;
    /**
     * List of group IDs representing the group owners of the feature.
     */
    readonly groupOwners: pulumi.Output<number[] | undefined>;
    /**
     * Determines the initial value of the feature.
     */
    readonly initialValue: pulumi.Output<string>;
    /**
     * Can be used to archive/unarchive a feature. If unspecified, it will default to false
     */
    readonly isArchived: pulumi.Output<boolean>;
    /**
     * List of user IDs representing the owners of the feature.
     */
    readonly owners: pulumi.Output<number[] | undefined>;
    /**
     * ID of the project
     */
    readonly projectId: pulumi.Output<number>;
    /**
     * UUID of project the feature belongs to
     */
    readonly projectUuid: pulumi.Output<string>;
    /**
     * List of tag IDs representing the tags attached to the feature.
     */
    readonly tags: pulumi.Output<number[] | undefined>;
    /**
     * Type of the feature, can be STANDARD, or MULTIVARIATE. if unspecified, it will default to STANDARD
     */
    readonly type: pulumi.Output<string>;
    /**
     * UUID of the feature
     */
    readonly uuid: pulumi.Output<string>;
    /**
     * Create a Feature resource with the given unique name, arguments, and options.
     *
     * @param name The _unique_ name of the resource.
     * @param args The arguments to use to populate this resource's properties.
     * @param opts A bag of options that control this resource's behavior.
     */
    constructor(name: string, args: FeatureArgs, opts?: pulumi.CustomResourceOptions);
}
/**
 * Input properties used for looking up and filtering Feature resources.
 */
export interface FeatureState {
    /**
     * Determines if the feature is enabled by default. If unspecified, it will default to false
     */
    defaultEnabled?: pulumi.Input<boolean | undefined>;
    /**
     * Description of the feature
     */
    description?: pulumi.Input<string | undefined>;
    /**
     * ID of the feature
     */
    featureId?: pulumi.Input<number | undefined>;
    /**
     * Name of the feature
     */
    featureName?: pulumi.Input<string | undefined>;
    /**
     * List of group IDs representing the group owners of the feature.
     */
    groupOwners?: pulumi.Input<pulumi.Input<number>[] | undefined>;
    /**
     * Determines the initial value of the feature.
     */
    initialValue?: pulumi.Input<string | undefined>;
    /**
     * Can be used to archive/unarchive a feature. If unspecified, it will default to false
     */
    isArchived?: pulumi.Input<boolean | undefined>;
    /**
     * List of user IDs representing the owners of the feature.
     */
    owners?: pulumi.Input<pulumi.Input<number>[] | undefined>;
    /**
     * ID of the project
     */
    projectId?: pulumi.Input<number | undefined>;
    /**
     * UUID of project the feature belongs to
     */
    projectUuid?: pulumi.Input<string | undefined>;
    /**
     * List of tag IDs representing the tags attached to the feature.
     */
    tags?: pulumi.Input<pulumi.Input<number>[] | undefined>;
    /**
     * Type of the feature, can be STANDARD, or MULTIVARIATE. if unspecified, it will default to STANDARD
     */
    type?: pulumi.Input<string | undefined>;
    /**
     * UUID of the feature
     */
    uuid?: pulumi.Input<string | undefined>;
}
/**
 * The set of arguments for constructing a Feature resource.
 */
export interface FeatureArgs {
    /**
     * Determines if the feature is enabled by default. If unspecified, it will default to false
     */
    defaultEnabled?: pulumi.Input<boolean | undefined>;
    /**
     * Description of the feature
     */
    description?: pulumi.Input<string | undefined>;
    /**
     * Name of the feature
     */
    featureName: pulumi.Input<string>;
    /**
     * List of group IDs representing the group owners of the feature.
     */
    groupOwners?: pulumi.Input<pulumi.Input<number>[] | undefined>;
    /**
     * Determines the initial value of the feature.
     */
    initialValue?: pulumi.Input<string | undefined>;
    /**
     * Can be used to archive/unarchive a feature. If unspecified, it will default to false
     */
    isArchived?: pulumi.Input<boolean | undefined>;
    /**
     * List of user IDs representing the owners of the feature.
     */
    owners?: pulumi.Input<pulumi.Input<number>[] | undefined>;
    /**
     * UUID of project the feature belongs to
     */
    projectUuid: pulumi.Input<string>;
    /**
     * List of tag IDs representing the tags attached to the feature.
     */
    tags?: pulumi.Input<pulumi.Input<number>[] | undefined>;
    /**
     * Type of the feature, can be STANDARD, or MULTIVARIATE. if unspecified, it will default to STANDARD
     */
    type?: pulumi.Input<string | undefined>;
}
//# sourceMappingURL=feature.d.ts.map